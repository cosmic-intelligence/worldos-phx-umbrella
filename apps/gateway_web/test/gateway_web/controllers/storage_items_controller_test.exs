defmodule GatewayWeb.StorageItemsControllerTest do
  use GatewayWeb.ConnCase, async: true

  alias Core.{Accounts, Servers, Storage}

  setup do
    # Create user and server fixtures
    {:ok, user} =
      Accounts.create_user(%{
        username: "testuser",
        email: "test@example.com",
        hashed_password: "hash"
      })

    {:ok, server} = Servers.create_server(%{name: "TestServer", owner_id: user.id})

    {:ok, user: user, server: server}
  end

  @create_attrs %{
    path: "/uploads/test.jpg",
    mime_type: "image/jpeg",
    byte_size: 12345
  }

  test "POST /api/storage_items creates a storage item", %{conn: conn, user: user, server: server} do
    attrs = Map.merge(@create_attrs, %{uploader_id: user.id, server_id: server.id})
    conn = post(conn, "/api/storage_items", attrs)
    resp = json_response(conn, 201)

    assert %{"id" => id, "path" => "/uploads/test.jpg"} = resp
    assert resp["uploader_id"] == user.id
    assert resp["server_id"] == server.id
    assert resp["mime_type"] == "image/jpeg"
    assert resp["byte_size"] == 12345

    assert %Storage.StorageItem{id: ^id} = Storage.get_storage_item!(id)
  end

  test "GET /api/storage_items lists storage items for server", %{
    conn: conn,
    user: user,
    server: server
  } do
    {:ok, item} =
      Storage.create_storage_item(%{
        path: "/uploads/test.jpg",
        mime_type: "image/jpeg",
        byte_size: 12345,
        uploader_id: user.id,
        server_id: server.id
      })

    conn = get(conn, "/api/storage_items", %{server_id: server.id})
    list = json_response(conn, 200)
    assert Enum.any?(list, fn %{"id" => id} -> id == item.id end)
  end

  test "GET /api/storage_items/:id shows storage item", %{conn: conn, user: user, server: server} do
    {:ok, item} =
      Storage.create_storage_item(%{
        path: "/uploads/test.jpg",
        mime_type: "image/jpeg",
        byte_size: 12345,
        uploader_id: user.id,
        server_id: server.id
      })

    conn = get(conn, "/api/storage_items/#{item.id}")
    resp = json_response(conn, 200)
    assert resp["id"] == item.id
    assert resp["path"] == "/uploads/test.jpg"
    assert resp["mime_type"] == "image/jpeg"
    assert resp["byte_size"] == 12345
    assert resp["uploader_id"] == user.id
    assert resp["server_id"] == server.id
  end

  @update_attrs %{
    path: "/uploads/updated.png",
    mime_type: "image/png",
    byte_size: 54321
  }

  test "PATCH /api/storage_items/:id updates storage item", %{
    conn: conn,
    user: user,
    server: server
  } do
    {:ok, item} =
      Storage.create_storage_item(%{
        path: "/uploads/test.jpg",
        mime_type: "image/jpeg",
        byte_size: 12345,
        uploader_id: user.id,
        server_id: server.id
      })

    conn = patch(conn, "/api/storage_items/#{item.id}", @update_attrs)
    resp = json_response(conn, 200)
    assert resp["path"] == "/uploads/updated.png"
    assert resp["mime_type"] == "image/png"
    assert resp["byte_size"] == 54321
  end

  test "PUT /api/storage_items/:id updates storage item", %{
    conn: conn,
    user: user,
    server: server
  } do
    {:ok, item} =
      Storage.create_storage_item(%{
        path: "/uploads/test.jpg",
        mime_type: "image/jpeg",
        byte_size: 12345,
        uploader_id: user.id,
        server_id: server.id
      })

    conn = put(conn, "/api/storage_items/#{item.id}", @update_attrs)
    resp = json_response(conn, 200)
    assert resp["path"] == "/uploads/updated.png"
    assert resp["mime_type"] == "image/png"
    assert resp["byte_size"] == 54321
  end

  test "DELETE /api/storage_items/:id deletes storage item", %{
    conn: conn,
    user: user,
    server: server
  } do
    {:ok, item} =
      Storage.create_storage_item(%{
        path: "/uploads/test.jpg",
        mime_type: "image/jpeg",
        byte_size: 12345,
        uploader_id: user.id,
        server_id: server.id
      })

    conn = delete(conn, "/api/storage_items/#{item.id}")
    assert response(conn, 204)
    assert_raise Ecto.NoResultsError, fn -> Storage.get_storage_item!(item.id) end
  end
end
