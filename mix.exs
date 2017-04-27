defmodule HappyReview.Mixfile do
  use Mix.Project

  def project do
    [app: :happy_review,
     version: "0.1.0",
     elixir: "~> 1.4",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    # Specify extra applications you'll use from Erlang/Elixir
    [mod: {HappyReview.Application, []},
     extra_applications: [:logger]]
  end

  defp aliases do
    ["test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:my_dep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:my_dep, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:cowboy, "~> 1.1"},
     {:plug, "~> 1.3"},
     {:ecto, "~> 2.1"},
     {:postgrex, "~> 0.13.2"},
     {:poison, "~> 3.1"}]
  end
end
