defmodule GatewayWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :gateway_web
  require Logger

  # PubSub configuration for real-time features (channels)
  @pubsub_server GatewayWeb.PubSub

  # The session will be stored in the cookie and signed,
  # this means its contents can be read but not tampered with.
  # Set :encryption_salt if you would also like to encrypt it.
  @session_options [
    store: :cookie,
    key: "_gateway_web_key",
    signing_salt: "GA5IGC/+",
    same_site: "Lax"
  ]

  # socket("/live", Phoenix.LiveView.Socket,
  #   websocket: [connect_info: [session: @session_options]],
  #   longpoll: [connect_info: [session: @session_options]]
  # )

  # WebSocket endpoint for React/Phoenix client
  socket("/socket", GatewayWeb.UserSocket,
    websocket: [
      connect_info: [:peer_data, :uri, session: @session_options],
      logger: {Logger, :log, [:info]}
    ],
    longpoll: false
  )

  # Serve at "/" the static files from "priv/static" directory.
  #
  # You should set gzip to true if you are running phx.digest
  # when deploying your static files in production.
  plug(Plug.Static,
    at: "/",
    from: :gateway_web,
    gzip: false,
    only: GatewayWeb.static_paths()
  )

  # Code reloading can be explicitly enabled under the
  # :code_reloader configuration of your endpoint.
  if code_reloading? do
    plug(Phoenix.CodeReloader)
    plug(Phoenix.Ecto.CheckRepoStatus, otp_app: :gateway_web)
  end

  plug(Plug.RequestId)
  plug(Plug.Telemetry, event_prefix: [:phoenix, :endpoint])

  # Allow Cross-Origin requests from the Electron app during local development
  plug(CORSPlug, origin: ["*"])

  plug(Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()
  )

  plug(Plug.MethodOverride)
  plug(Plug.Head)
  plug(Plug.Session, @session_options)
  plug(GatewayWeb.Router)
end
