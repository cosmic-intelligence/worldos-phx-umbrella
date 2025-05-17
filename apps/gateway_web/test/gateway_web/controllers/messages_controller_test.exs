defmodule GatewayWeb.MessagesControllerTest do
  use GatewayWeb.ConnCase, async: true

  alias Core.{Accounts, Servers, Messaging}

  setup do
    # Create user, server and channel fixtures
    {:ok, user} =
      Accounts.create_user(%{
        username: "testuser",
        email: "test@example.com",
        hashed_password: "hash"
      })

    {:ok, server} = Servers.create_server(%{name: "TestServer", owner_id: user.id})
    {:ok, channel} = Servers.create_channel(%{name: "general", position: 0, server_id: server.id})

    {:ok, user: user, server: server, channel: channel}
  end

  @create_attrs %{content: "Hello, world!"}

  test "POST /api/messages creates a message", %{conn: conn, user: user, channel: channel} do
    attrs = Map.merge(@create_attrs, %{author_id: user.id, channel_id: channel.id})
    conn = post(conn, "/api/messages", attrs)
    resp = json_response(conn, 201)

    assert %{"id" => id, "content" => "Hello, world!"} = resp
    assert resp["author_id"] == user.id
    assert resp["channel_id"] == channel.id

    assert %Messaging.Message{id: ^id} = Messaging.get_message!(id)
  end

  test "GET /api/messages lists messages for channel", %{conn: conn, user: user, channel: channel} do
    {:ok, message} =
      Messaging.create_message(%{
        content: "Test message",
        author_id: user.id,
        channel_id: channel.id
      })

    conn = get(conn, "/api/messages", %{channel_id: channel.id})
    list = json_response(conn, 200)
    assert Enum.any?(list, fn %{"id" => id} -> id == message.id end)
  end

  test "GET /api/messages/:id shows message", %{conn: conn, user: user, channel: channel} do
    {:ok, message} =
      Messaging.create_message(%{
        content: "Test message",
        author_id: user.id,
        channel_id: channel.id
      })

    conn = get(conn, "/api/messages/#{message.id}")
    resp = json_response(conn, 200)
    assert resp["id"] == message.id
    assert resp["content"] == "Test message"
    assert resp["author_id"] == user.id
    assert resp["channel_id"] == channel.id
  end

  @update_attrs %{content: "Updated content"}

  test "PATCH /api/messages/:id updates message", %{conn: conn, user: user, channel: channel} do
    {:ok, message} =
      Messaging.create_message(%{
        content: "Original content",
        author_id: user.id,
        channel_id: channel.id
      })

    conn = patch(conn, "/api/messages/#{message.id}", @update_attrs)
    resp = json_response(conn, 200)
    assert resp["content"] == "Updated content"
  end

  test "PUT /api/messages/:id updates message", %{conn: conn, user: user, channel: channel} do
    {:ok, message} =
      Messaging.create_message(%{
        content: "Original content",
        author_id: user.id,
        channel_id: channel.id
      })

    conn = put(conn, "/api/messages/#{message.id}", @update_attrs)
    resp = json_response(conn, 200)
    assert resp["content"] == "Updated content"
  end

  test "DELETE /api/messages/:id deletes message", %{conn: conn, user: user, channel: channel} do
    {:ok, message} =
      Messaging.create_message(%{
        content: "Test message",
        author_id: user.id,
        channel_id: channel.id
      })

    conn = delete(conn, "/api/messages/#{message.id}")
    assert response(conn, 204)
    assert_raise Ecto.NoResultsError, fn -> Messaging.get_message!(message.id) end
  end
end
