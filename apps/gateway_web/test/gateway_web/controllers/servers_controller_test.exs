defmodule GatewayWeb.ServersControllerTest do
  use GatewayWeb.ConnCase, async: true

  alias Core.{Accounts, Servers}

  setup do
    {:ok, owner} =
      Accounts.create_user(%{
        username: "owner",
        email: "owner@example.com",
        hashed_password: "hash"
      })

    {:ok, owner: owner}
  end

  @create_attrs %{name: "Test World", is_public: true}

  test "POST /api/servers creates a server", %{conn: conn, owner: owner} do
    conn = post(conn, "/api/servers", Map.put(@create_attrs, :owner_id, owner.id))
    resp = json_response(conn, 201)
    assert %{"id" => id, "name" => "Test World", "is_public" => true} = resp
    assert resp["owner_id"] == owner.id

    assert %Servers.Server{id: ^id} = Servers.get_server!(id)
  end

  test "GET /api/servers lists servers", %{conn: conn, owner: owner} do
    {:ok, srv} = Servers.create_server(Map.put(@create_attrs, :owner_id, owner.id))
    conn = get(conn, "/api/servers")
    list = json_response(conn, 200)
    assert Enum.any?(list, fn %{"id" => id} -> id == srv.id end)
  end

  test "GET /api/servers/:id shows server", %{conn: conn, owner: owner} do
    {:ok, srv} = Servers.create_server(Map.put(@create_attrs, :owner_id, owner.id))
    conn = get(conn, "/api/servers/#{srv.id}")
    resp = json_response(conn, 200)
    assert resp["id"] == srv.id
    assert resp["name"] == "Test World"
  end

  @update_attrs %{name: "Updated", is_public: false}

  test "PATCH /api/servers/:id updates server", %{conn: conn, owner: owner} do
    {:ok, srv} = Servers.create_server(Map.put(@create_attrs, :owner_id, owner.id))
    conn = patch(conn, "/api/servers/#{srv.id}", @update_attrs)
    assert %{"name" => "Updated", "is_public" => false} = json_response(conn, 200)
  end

  test "DELETE /api/servers/:id deletes server", %{conn: conn, owner: owner} do
    {:ok, srv} = Servers.create_server(Map.put(@create_attrs, :owner_id, owner.id))
    conn = delete(conn, "/api/servers/#{srv.id}")
    assert response(conn, 204)
    assert_raise Ecto.NoResultsError, fn -> Servers.get_server!(srv.id) end
  end
end
