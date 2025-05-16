import Config

# Configure your database
config :core, Core.Repo,
  username: "seppe",
  password: "",
  hostname: "localhost",
  database: "pg-chat_test",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: 10

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :core, server: false

# Print only warnings and errors during test
config :logger, level: :warning
