defmodule MixTestInteractive.MixProject do
  use Mix.Project

  @version "3.2.1"
  @source_url "https://github.com/randycoulman/mix_test_interactive"

  def project do
    [
      app: :mix_test_interactive,
      deps: deps(),
      description: description(),
      docs: docs(),
      elixir: "~> 1.13",
      name: "mix test.interactive",
      package: package(),
      source_url: @source_url,
      start_permanent: Mix.env() == :prod,
      version: @version
    ]
  end

  def application do
    [
      extra_applications: [:logger, :file_system],
      mod: {MixTestInteractive.Application, []}
    ]
  end

  defp description do
    "Interactive test runner for mix test with watch mode."
  end

  defp deps do
    [
      {:ex_doc, "~> 0.34.2", only: :dev, runtime: false},
      {:file_system, "~> 0.2 or ~> 1.0"},
      {:process_tree, "~> 0.1.3"},
      {:styler, "~> 0.11.9", only: [:dev, :test], runtime: false},
      {:typed_struct, "~> 0.3.0"}
    ]
  end

  defp docs do
    [
      extras: [
        "CHANGELOG.md": [],
        "LICENSE.md": [title: "License"],
        "README.md": [title: "Overview"]
      ],
      formatters: ["html"],
      groups_for_modules: [
        Commands: [~r/^MixTestInteractive\.Command\..*/]
      ],
      main: "readme",
      source_ref: "#{@version}"
    ]
  end

  defp package do
    [
      licenses: ["MIT"],
      links: %{
        "Changelog" => "https://hexdocs.pm/mix_test_interactive/changelog.html",
        "GitHub" => @source_url
      }
    ]
  end
end
