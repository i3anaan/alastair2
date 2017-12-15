# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :alastair,
  ecto_repos: [Alastair.Repo]

# Configures the endpoint
config :alastair, Alastair.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "oqB2ztYgIK5jP7iYgJetbbU1BfQEJ0q3glzvwT0by8GNw7bS9V5eBKOBLxRTkNip",
  render_errors: [view: Alastair.ErrorView, accepts: ~w(html json)],
  pubsub: [name: Alastair.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
# import_config "#{Mix.env}.exs"
import_config "prod_hotfix.exs"
