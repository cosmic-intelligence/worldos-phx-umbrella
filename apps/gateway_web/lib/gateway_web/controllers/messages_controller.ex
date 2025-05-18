defmodule GatewayWeb.MessagesController do
  use GatewayWeb, :controller
  alias Core.Messaging
  alias GatewayWeb.ControllerHelpers, as: Helpers

  def index(conn, params) do
    channel_id = Map.get(params, "channel_id")
    json(conn, Enum.map(Messaging.list_messages(channel_id), &serialize/1))
  end

  def show(conn, %{"id" => id}) do
    json(conn, serialize(Messaging.get_message!(id)))
  end

  def create(conn, params) do
    case Messaging.create_message(params) do
      {:ok, msg} ->
        # Broadcast on channel:<channel_id> topic so connected clients get it.
        # Use try to avoid crashing when PubSub not started (e.g., in CLI script)
        try do
          GatewayWeb.Endpoint.broadcast(
            "channel:#{msg.channel_id}",
            "new_message",
            serialize(msg)
          )
        rescue
          # Silently continue when PubSub is not available
          _ -> :ok
        end

        conn |> put_status(:created) |> json(serialize(msg))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    msg = Messaging.get_message!(id)

    case Messaging.update_message(msg, Map.delete(params, "id")) do
      {:ok, msg} ->
        json(conn, serialize(msg))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    msg = Messaging.get_message!(id)
    {:ok, _} = Messaging.delete_message(msg)
    send_resp(conn, :no_content, "")
  end

  defp serialize(m),
    do: %{
      id: m.id,
      content: m.content,
      channel_id: m.channel_id,
      author_id: m.author_id,
      inserted_at: m.inserted_at
    }
end
