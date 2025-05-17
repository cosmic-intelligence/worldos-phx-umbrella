defmodule GatewayWeb.MembershipsControllerTest do
  use GatewayWeb.ConnCase, async: true

  alias Core.{Accounts, Servers}

  setup do
    # Create two users and a server
    {:ok, user} =
      Accounts.create_user(%{username: "user1", email: "u1@example.com", hashed_password: "hash"})

    {:ok, server} = Servers.create_server(%{name: "Srv", owner_id: user.id})

    {:ok, user: user, server: server}
  end

  test "POST /api/memberships creates membership", %{conn: conn, user: user, server: srv} do
    params = %{user_id: user.id, server_id: srv.id, role: 1}
    conn = post(conn, "/api/memberships", params)
    resp = json_response(conn, 201)
    assert resp["user_id"] == user.id
    assert resp["server_id"] == srv.id
    assert resp["role"] == 1
  end

  test "GET /api/memberships filters by server", %{conn: conn, user: user, server: srv} do
    # prepare membership
    {:ok, _} = Servers.create_membership(%{user_id: user.id, server_id: srv.id})

    conn = get(conn, "/api/memberships", %{server_id: srv.id})
    list = json_response(conn, 200)
    assert Enum.any?(list, fn %{"server_id" => id} -> id == srv.id end)
  end

  test "DELETE /api/memberships deletes membership", %{conn: conn, user: user, server: srv} do
    {:ok, _} = Servers.create_membership(%{user_id: user.id, server_id: srv.id})

    conn = delete(conn, "/api/memberships", %{user_id: user.id, server_id: srv.id})
    assert response(conn, 204)

    # index should now be empty
    conn = get(conn, "/api/memberships", %{user_id: user.id, server_id: srv.id})
    assert json_response(conn, 200) == []
  end
end
