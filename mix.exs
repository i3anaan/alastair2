defmodule Alastair.Mixfile do
  use Mix.Project

  def project do
    [app: :alastair,
     version: "0.0.1",
     elixir: "~> 1.2",
     elixirc_paths: elixirc_paths(Mix.env),
     compilers: [:phoenix, :gettext] ++ Mix.compilers,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     aliases: aliases(),
     deps: deps(),
     test_coverage: coverex()
   ]
  end

  # Configure coverex to ignore all phoenix generated files and unnecessary things
  def coverex do
    [tool: Coverex.Task,
    coveralls: true,
    ignore_modules: [
      Elixir.Alastair,
      Elixir.Alastair.Router.Helpers,
      Elixir.Alastair.Router, 
      Elixir.Alastair.Repo, 
      Elixir.Alastair.Seeds,
      Elixir.Alastair.Seeds.CurrencySeed,
      Elixir.Alastair.Seeds.ExampleSeed,
      Elixir.Alastair.Seeds.IngredientSeed,
      Elixir.Alastair.Seeds.MeasurementSeed,
      Elixir.Phoenix.Param.Alastair.Event,
      Elixir.Poison.Encoder.Alastair.Notification,
      Elixir.Alastair.Web,
      Elixir.Alastair.ChannelCase,
      Elixir.Alastair.ConnCase,
      Elixir.Alastair.ModelCase,
      Elixir.Alastair.Gettext,
      Elixir.Alastair.ChangesetView,
      Elixir.Alastair.ErrorView,
      Elixir.Alastair.ErrorHelpers,
      Elixir.Alastair.Endpoint
    ]]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [mod: {Alastair, []},
     applications: [:phoenix, :phoenix_pubsub, :phoenix_html, :cowboy, :logger, :gettext,
                    :phoenix_ecto, :postgrex, :httpoison]]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "web", "test/support"]
  defp elixirc_paths(_),     do: ["lib", "web"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [{:phoenix, "~> 1.2.4"},
     {:phoenix_pubsub, "~> 1.0"},
     {:phoenix_ecto, "~> 3.0"},
     {:postgrex, ">= 0.0.0"},
     {:phoenix_html, "~> 2.6"},
     {:phoenix_live_reload, "~> 1.0", only: :dev},
     {:gettext, "~> 0.11"},
     {:cowboy, "~> 1.0"},
     {:ecto_enum, "~> 1.0"},
     {:httpoison, "~> 0.13"},
     {:coverex, "~> 1.4.10"}
   ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    ["ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
     "ecto.reset": ["ecto.drop", "ecto.setup"],
     "test": ["ecto.create --quiet", "ecto.migrate", "test"]]
  end
end
