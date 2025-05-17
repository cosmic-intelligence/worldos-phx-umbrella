defmodule GatewayWeb.ChannelsController do
  use GatewayWeb, :controller
  alias Core.Servers
  alias GatewayWeb.ControllerHelpers, as: Helpers

  def index(conn, params) do
    server_id = Map.get(params, "server_id")
    json(conn, Enum.map(Servers.list_channels(server_id), &serialize/1))
  end

  def show(conn, %{"id" => id}) do
    json(conn, serialize(Servers.get_channel!(id)))
  end

  def create(conn, params) do
    case Servers.create_channel(params) do
      {:ok, ch} ->
        conn |> put_status(:created) |> json(serialize(ch))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    ch = Servers.get_channel!(id)

    case Servers.update_channel(ch, Map.delete(params, "id")) do
      {:ok, ch} ->
        json(conn, serialize(ch))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    ch = Servers.get_channel!(id)
    {:ok, _} = Servers.delete_channel(ch)
    send_resp(conn, :no_content, "")
  end

  defp serialize(c),
    do: %{
      id: c.id,
      name: c.name,
      position: c.position,
      is_private: c.is_private,
      server_id: c.server_id
    }
end
