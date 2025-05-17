defmodule GatewayWeb.ServersController do
  use GatewayWeb, :controller
  alias Core.Servers
  alias GatewayWeb.ControllerHelpers, as: Helpers

  def index(conn, _params) do
    json(conn, Enum.map(Servers.list_servers(), &serialize/1))
  end

  def show(conn, %{"id" => id}) do
    json(conn, serialize(Servers.get_server!(id)))
  end

  def create(conn, params) do
    case Servers.create_server(params) do
      {:ok, server} ->
        conn |> put_status(:created) |> json(serialize(server))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    server = Servers.get_server!(id)

    case Servers.update_server(server, Map.delete(params, "id")) do
      {:ok, server} ->
        json(conn, serialize(server))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    server = Servers.get_server!(id)
    {:ok, _} = Servers.delete_server(server)
    send_resp(conn, :no_content, "")
  end

  defp serialize(s), do: %{id: s.id, name: s.name, is_public: s.is_public, owner_id: s.owner_id}
end
