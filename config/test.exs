use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :alastair, Alastair.Endpoint,
  http: [port: 4001],
  server: false,
  user_service: :static_user,
  event_service: :static_event

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :alastair, Alastair.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "postgres",
  database: "alastair_test",
  hostname: "postgres-alastair",
  pool: Ecto.Adapters.SQL.Sandbox
