defmodule PublishPlus.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :publish_plus,
      version: @version,
      elixir: "~> 1.3",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      package: package(),

      # Docs
      name: "PublishPlus",
      docs: [
        source_ref: "v#{@version}",
        source_url: "https://github.com/wojtekmach/publish_plus",
        main: "readme",
        extras: ["README.md"]
      ]
    ]
  end

  def application do
    [
      applications: [:logger]
    ]
  end

  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev}
    ]
  end

  def package do
    [
      description: "PublishPlus is an opinionated package publisher for Elixir",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/wojtekmach/publish_plus"},
      maintainers: ["Wojtek Mach"],
    ]
  end
end
