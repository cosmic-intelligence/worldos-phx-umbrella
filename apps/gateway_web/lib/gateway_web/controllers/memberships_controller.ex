defmodule GatewayWeb.MembershipsController do
  use GatewayWeb, :controller
  alias Core.Servers
  alias GatewayWeb.ControllerHelpers, as: Helpers

  # Index filtered by user_id/server_id or both
  def index(conn, params) do
    opts =
      Enum.filter(params, fn {k, _} -> k in ["user_id", "server_id"] end)
      |> Enum.map(fn {k, v} -> {String.to_atom(k), v} end)

    memberships = Servers.list_memberships(opts)
    json(conn, Enum.map(memberships, &serialize/1))
  end

  def create(conn, params) do
    case Servers.create_membership(params) do
      {:ok, m} ->
        conn |> put_status(:created) |> json(serialize(m))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  # delete expects user_id & server_id in query/body
  def delete(conn, params) do
    with %{"user_id" => uid, "server_id" => sid} <- params do
      memb = Servers.get_membership!(uid, sid)
      {:ok, _} = Servers.delete_membership(memb)
      send_resp(conn, :no_content, "")
    else
      _ -> conn |> put_status(:bad_request) |> json(%{error: "user_id and server_id required"})
    end
  end

  defp serialize(m),
    do: %{user_id: m.user_id, server_id: m.server_id, role: m.role, joined_at: m.joined_at}
end
