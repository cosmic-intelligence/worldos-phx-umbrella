import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :gateway_web, GatewayWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "7xXuZuhAz/LrxNDv1GEU472bBh0bWElZTIWH5WGO9b2/Tb7bZpyYDVEmSbS/3XTG",
  server: false

# Configure your database
#
# The MIX_TEST_PARTITION environment variable can be used
# to provide built-in test partitioning in CI environment.
# Run `mix help test` for more information.
config :core, Core.Repo,
  username: "seppe",
  password: "",
  hostname: "localhost",
  database: "pg-chat_test#{System.get_env("MIX_TEST_PARTITION")}",
  pool: Ecto.Adapters.SQL.Sandbox,
  pool_size: System.schedulers_online() * 2
