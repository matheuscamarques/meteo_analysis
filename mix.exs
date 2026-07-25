defmodule MeteoAnalysis.MixProject do
  use Mix.Project

  def project do
    [
      app: :meteo_analisys,
      version: "0.1.0",
      elixir: "~> 1.20",
      start_permanent: Mix.env() == :prod,
      test_coverage: [tool: ExCoveralls, summary: [threshold: 90]],
      deps: deps()
    ]
  end

  def cli do
    [
      preferred_envs: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {MeteoAnalysis.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.5.0"},
      {:jason, "~> 1.4"},
      {:mox, "~> 1.1", only: :test},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.18", only: :test},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:stream_data, "~> 1.1", only: :test},
      {:sobelow, "~> 0.13", only: [:dev, :test], runtime: false},
      {:doctor, "~> 0.22", only: [:dev, :test], runtime: false}
    ]
  end
end
