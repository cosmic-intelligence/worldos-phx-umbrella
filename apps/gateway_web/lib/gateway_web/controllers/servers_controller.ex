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
        # Broadcast to all clients interested in server changes
        # Use try to avoid crashing when PubSub not started (e.g., in CLI script)
        try do
          GatewayWeb.Endpoint.broadcast("server:all", "new_server", serialize(server))
        rescue
          # Silently continue when PubSub is not available
          _ -> :ok
        end

        conn |> put_status(:created) |> json(serialize(server))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    server = Servers.get_server!(id)

    case Servers.update_server(server, Map.delete(params, "id")) do
      {:ok, server} ->
        # Broadcast to both the "all" topic and the specific server topic
        # Use try to avoid crashing when PubSub not started (e.g., in CLI script)
        try do
          GatewayWeb.Endpoint.broadcast("server:all", "updated_server", serialize(server))

          GatewayWeb.Endpoint.broadcast(
            "server:#{server.id}",
            "updated_server",
            serialize(server)
          )
        rescue
          # Silently continue when PubSub is not available
          _ -> :ok
        end

        json(conn, serialize(server))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    server = Servers.get_server!(id)
    # Broadcast deletion to both topics before actually deleting
    # Use try to avoid crashing when PubSub not started (e.g., in CLI script)
    try do
      GatewayWeb.Endpoint.broadcast("server:all", "deleted_server", %{id: server.id})
      GatewayWeb.Endpoint.broadcast("server:#{server.id}", "deleted_server", %{id: server.id})
    rescue
      # Silently continue when PubSub is not available
      _ -> :ok
    end

    {:ok, _} = Servers.delete_server(server)
    send_resp(conn, :no_content, "")
  end

  defp serialize(s), do: %{id: s.id, name: s.name, is_public: s.is_public, owner_id: s.owner_id}
end
