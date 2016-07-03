defmodule Bakeit.CLI do
  @moduledoc false

  @app_version Mix.Project.config()[:version]
  @app_id Mix.Project.config()[:app]

  @switches [
    help: :boolean, title: :binary, language: :binary, duration:
    :integer, max_views: :integer, open_browser: :boolean, debug: :boolean,
    version: :boolean
  ]

  @aliases [
    h: :help, t: :title, l: :language, d: :duration,
    v: :max_views, b: :open_browser, 'D': :debug, 'V': :version
  ]

  def main(argv) do
    argv
    |> parse_args
    |> process
  end

  def parse_args(args) do
    parse = OptionParser.parse(args, switches: @switches, aliases: @aliases)

    case parse do
      { [help: true] , _ , _ }    -> :help
      { [version: true] , _ , _ } -> :version
      { options , [input], _ }    -> { input, options }
      { options , [], _ }         -> { "", options }
      _ -> :help
    end

  end

  def help_message() do
  """
  Usage: bakeit [-t [<title>]] [-l [<language>]] [-d [<duration>]]
                [-v [<max_views>]] [-b [<open_browser>]] [-D [<debug>]]
                [-h] [-V] [<filename>]

    -t, --title         The title of the paste [default: ]
    -l, --lang          The language highlighter to use [default: ]
    -d, --duration      The duration the paste should live for [default: 60]
    -v, --max-views     How many times the paste can be viewed before it
                        expires [default: 0]
    -b, --open-browser  Automatically open a browser window when done
                        [default: false]
    -D, --debug         Show debug info [default: false]
    -h, --help          Show this screen
    -V, --version       Show version
    <filename>          Input file, or omit for stdin
  """
  end

  def process(:help) do
    IO.write help_message
  end

  def process(:version) do
    IO.write "#{@app_id} #{@app_version}\n"
  end

  def process({ input, options }) do
    if options_contains_unknown_values(options) do
        process(:help)
    else
        do_process(input, options)
    end
  end

  def do_process(input, options) do
    bakeit_opts = %{
      title: Keyword.get(options, :title, ""),
      language: Keyword.get(options, :language, ""),
      duration: Keyword.get(options, :duration, 60),
      max_views: Keyword.get(options, :max_views, 0),
      open_browser: Keyword.get(options, :open_browser, false),
      debug: Keyword.get(options, :debug, false)
    }

    Bakeit.upload(input, bakeit_opts)
  end

  defp options_contains_unknown_values(options) do
    Enum.any?(options, fn({key, _value}) ->
      if key in Keyword.keys(@switches) do
        false
      else
        true
      end
    end)
  end
end

