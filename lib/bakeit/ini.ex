defmodule Bakeit.INIError do
  defexception [:message]

  def exception(opts) do
    message = opts[:message]
    %Bakeit.INIError{message: message}
  end
end

defmodule Bakeit.INI do
  @moduledoc false

  @cfg_path ".config/bakeit.cfg"

  alias Bakeit.INIError

  def read() do
    %{api_key: [home_dir(), @cfg_path]
               |> Path.join
               |> load_from_file
               |> section(:pastery)
               |> get(:api_key, :pastery)
     }
  end

  def home_dir() do
    System.get_env("HOME") ||
      raise INIError, message: "No HOME environment variable!"
  end

  def load_from_file(filename) do
    case File.read filename do
      {:ok, ini} ->
        Ini.decode(ini)
      _  ->
        raise INIError, message:
          "Config file not found. Make sure you have a config file " <>
          "at ~/#{@cfg_path} with a [pastery] section containing " <>
          "your Pastery API key, which you can get from your " <>
          "https://www.pastery.net account page."
    end
  end

  def section(config, section) do
    config[section] || raise INIError, message:
      "[#{section}] section not found. Please add a [#{section}] " <>
      "section to the ~/#{@cfg_path} file and try again."
  end

  def get(section, key, section_name) do
    section[key] || raise INIError, message:
      "No #{key} entry found. Please add an entry for #{key} to the" <>
      "[#{section_name}] section with your API key in it. You can find the" <>
      "latter on your account page on https://www.pastery.net."
  end
end
