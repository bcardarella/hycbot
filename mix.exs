defmodule Hycbot.MixProject do
  use Mix.Project

  def project do
    [
      app: :hycbot,
      version: "0.1.0",
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      elixirc_paths: elixirc_paths(Mix.env())
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {HYCBot.Application, []},
      extra_applications: [:logger, :eex]
    ]
  end

  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2.2"},
      {:httpoison, "~> 1.8.0"},
      {:tzdata, "~> 1.1.0"},
      {:quantum, "~> 3.0"},
      {:gen_tcp_accept_and_close, "~> 0.1.0"}
    ]
  end
end
