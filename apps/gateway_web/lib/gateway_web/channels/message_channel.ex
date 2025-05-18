defmodule GatewayWeb.MessageChannel do
  use Phoenix.Channel
  require Logger

  @impl true
  def join("channel:" <> channel_id, _params, socket) do
    Logger.info("Client joined message channel: channel:#{channel_id}")
    # Add channel_id to socket assigns
    socket = assign(socket, :channel_id, channel_id)
    {:ok, socket}
  end

  # Handle the specific new_message event as expected by frontend
  @impl true
  def handle_in("new_message", %{"body" => body} = payload, socket) do
    channel_id = socket.assigns.channel_id
    Logger.info("New message in channel:#{channel_id}: #{inspect(body)}")
    # Broadcast the message to all clients in this channel
    broadcast!(socket, "new_message", payload)
    {:reply, :ok, socket}
  end

  # Generic handler for other events (for backward compatibility)
  @impl true
  def handle_in(event, payload, socket) do
    channel_id = socket.assigns.channel_id
    Logger.info("Event '#{event}' in channel:#{channel_id}: #{inspect(payload)}")
    broadcast!(socket, event, payload)
    {:noreply, socket}
  end
end
