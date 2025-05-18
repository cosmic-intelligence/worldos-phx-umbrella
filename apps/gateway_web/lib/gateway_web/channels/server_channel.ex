defmodule GatewayWeb.ServerChannel do
  use Phoenix.Channel
  require Logger
  # alias Core.Servers # Example: if your server logic is in Core

  @impl true
  def join("server:" <> server_id, _params, socket) do
    user_id = socket.assigns.user_id

    # Basic check: Is the user authenticated?
    if user_id do
      # TODO: Add proper authorization: Does this user_id have access to this server_id?
      # For example: if Core.Servers.can_user_access_server?(user_id, server_id) do
      Logger.info("User #{user_id} joined server channel: server:#{server_id}")
      socket = assign(socket, :server_id, server_id)
      {:ok, socket}
      # else
      #   Logger.warning("User #{user_id} unauthorized for server channel: server:#{server_id}")
      #   {:error, %{reason: "forbidden"}}
      # end
    else
      Logger.warning("Unauthenticated attempt to join server channel: server:#{server_id}")
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_in("new_message", %{"body" => body} = payload, socket) do
    server_id = socket.assigns.server_id
    Logger.info("New message in server:#{server_id}: #{inspect(body)}")
    broadcast!(socket, "new_message", payload)
    {:reply, :ok, socket}
  end

  @impl true
  def handle_in(event, payload, socket) do
    server_id = socket.assigns.server_id
    Logger.info("Event '#{event}' in server:#{server_id}: #{inspect(payload)}")
    broadcast!(socket, event, payload)
    {:noreply, socket}
  end
end
