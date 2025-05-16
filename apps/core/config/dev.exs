import Config

config :core, Core.Repo,
  username: "seppe",
  password: "",
  hostname: "localhost",
  database: "pg-chat",
  port: 5432,
  stacktrace: true,
  show_sensitive_data_on_connection_error: true,
  pool_size: 10
