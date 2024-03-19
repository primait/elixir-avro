defmodule ElixirAvro.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_avro,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {ElixirAvro.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:avrora, "~> 0.21"},
      {:credo, "~> 1.7"},
      {:decimal, "~> 2.0"},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:excribe, "~> 0.1.1"},
      {:timex, "~> 3.7.11"},
      {:typed_struct, "~> 0.3.0"},
      {:uuid, "~> 1.1.8"}
    ]
  end
end
