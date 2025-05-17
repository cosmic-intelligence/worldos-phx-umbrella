defmodule GatewayWeb.ChannelsControllerTest do
  use GatewayWeb.ConnCase, async: true

  alias Core.{Accounts, Servers}

  setup do
    # Owner & server fixture
    {:ok, owner} =
      Accounts.create_user(%{
        username: "owner",
        email: "owner@example.com",
        hashed_password: "hash"
      })

    {:ok, server} = Servers.create_server(%{name: "Srv", owner_id: owner.id})

    {:ok, owner: owner, server: server}
  end

  @create_attrs %{name: "general", position: 0, is_private: false}

  test "POST /api/channels creates channel", %{conn: conn, server: srv} do
    attrs = Map.put(@create_attrs, :server_id, srv.id)
    conn = post(conn, "/api/channels", attrs)
    resp = json_response(conn, 201)
    assert %{"id" => id, "name" => "general"} = resp
    assert resp["server_id"] == srv.id

    assert %Servers.Channel{id: ^id} = Servers.get_channel!(id)
  end

  test "GET /api/channels lists channels for server", %{conn: conn, server: srv} do
    {:ok, ch} = Servers.create_channel(%{name: "general", position: 0, server_id: srv.id})

    conn = get(conn, "/api/channels", %{server_id: srv.id})
    list = json_response(conn, 200)
    assert Enum.any?(list, fn %{"id" => id} -> id == ch.id end)
  end

  test "GET /api/channels/:id shows channel", %{conn: conn, server: srv} do
    {:ok, ch} = Servers.create_channel(%{name: "general", position: 0, server_id: srv.id})
    conn = get(conn, "/api/channels/#{ch.id}")
    resp = json_response(conn, 200)
    assert resp["id"] == ch.id
    assert resp["name"] == "general"
  end

  @update_attrs %{name: "random", position: 1, is_private: true}

  test "PATCH /api/channels/:id updates channel", %{conn: conn, server: srv} do
    {:ok, ch} = Servers.create_channel(%{name: "general", position: 0, server_id: srv.id})
    conn = patch(conn, "/api/channels/#{ch.id}", @update_attrs)
    resp = json_response(conn, 200)
    assert resp["name"] == "random"
    assert resp["is_private"] == true
  end

  test "DELETE /api/channels/:id deletes channel", %{conn: conn, server: srv} do
    {:ok, ch} = Servers.create_channel(%{name: "general", position: 0, server_id: srv.id})
    conn = delete(conn, "/api/channels/#{ch.id}")
    assert response(conn, 204)
    assert_raise Ecto.NoResultsError, fn -> Servers.get_channel!(ch.id) end
  end
end
