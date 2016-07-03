defmodule Bakeit.Mixfile do
  use Mix.Project

  def project do
    [
      app: :bakeit,
      version: "0.1.0",
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      escript: escript_config,
      deps: deps,
      description: description,
      package: package,
      docs: [
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [applications: [:logger, :httpoison]]
  end

  defp deps do
    [
      {:httpoison, "~> 0.9.0"},
      {:poison, "~> 2.0"},
      {:ini, "~> 0.0.1"},
      {:webbrowser, git: "https://github.com/efine/webbrowser.git", branch: "master"}
    ]
  end

  defp escript_config do
    [main_module: Bakeit.CLI, name: "bakeit"]
  end

  defp description do
    """
    BakeIt: a command line utility to [Pastery](https://www.pastery.net), the best
    pastebin in the world.
    """
  end

  defp package do
    [
      files: ["lib", "mix.exs", "README*", "LICENSE*"],
      maintainers: ["Edwin Fine"],
      licenses: ["Modified BSD License"],
      links: %{
        "GitHub" => "https://github.com/efine/bakeit_ex"
      },
      build_tools: ["mix"]
    ]
  end

end

