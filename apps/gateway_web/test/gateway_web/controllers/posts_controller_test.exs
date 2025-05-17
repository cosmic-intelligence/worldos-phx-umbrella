defmodule GatewayWeb.PostsControllerTest do
  use GatewayWeb.ConnCase, async: true

  alias Core.{Accounts, Servers, Content}

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
    slug: "test-post",
    title: "Test Post",
    html_content: "<p>This is a test post</p>",
    is_public: true
  }

  test "POST /api/posts creates a post", %{conn: conn, user: user, server: server} do
    attrs = Map.merge(@create_attrs, %{author_id: user.id, server_id: server.id})
    conn = post(conn, "/api/posts", attrs)
    resp = json_response(conn, 201)

    assert %{"id" => id, "title" => "Test Post"} = resp
    assert resp["author_id"] == user.id
    assert resp["server_id"] == server.id
    assert resp["slug"] == "test-post"
    assert resp["html_content"] == "<p>This is a test post</p>"
    assert resp["is_public"] == true

    assert %Content.Post{id: ^id} = Content.get_post!(id)
  end

  test "GET /api/posts lists posts for server", %{conn: conn, user: user, server: server} do
    {:ok, post} =
      Content.create_post(%{
        slug: "test-post",
        title: "Test Post",
        html_content: "<p>Content</p>",
        is_public: true,
        author_id: user.id,
        server_id: server.id
      })

    conn = get(conn, "/api/posts", %{server_id: server.id})
    list = json_response(conn, 200)
    assert Enum.any?(list, fn %{"id" => id} -> id == post.id end)
  end

  test "GET /api/posts/:id shows post", %{conn: conn, user: user, server: server} do
    {:ok, post} =
      Content.create_post(%{
        slug: "test-post",
        title: "Test Post",
        html_content: "<p>Content</p>",
        is_public: true,
        author_id: user.id,
        server_id: server.id
      })

    conn = get(conn, "/api/posts/#{post.id}")
    resp = json_response(conn, 200)
    assert resp["id"] == post.id
    assert resp["title"] == "Test Post"
    assert resp["slug"] == "test-post"
    assert resp["html_content"] == "<p>Content</p>"
    assert resp["is_public"] == true
    assert resp["author_id"] == user.id
    assert resp["server_id"] == server.id
  end

  @update_attrs %{
    title: "Updated Post",
    html_content: "<p>Updated content</p>",
    is_public: false
  }

  test "PATCH /api/posts/:id updates post", %{conn: conn, user: user, server: server} do
    {:ok, post} =
      Content.create_post(%{
        slug: "test-post",
        title: "Original Post",
        html_content: "<p>Original content</p>",
        is_public: true,
        author_id: user.id,
        server_id: server.id
      })

    conn = patch(conn, "/api/posts/#{post.id}", @update_attrs)
    resp = json_response(conn, 200)
    assert resp["title"] == "Updated Post"
    assert resp["html_content"] == "<p>Updated content</p>"
    assert resp["is_public"] == false
    # Slug should remain unchanged
    assert resp["slug"] == "test-post"
  end

  test "PUT /api/posts/:id updates post", %{conn: conn, user: user, server: server} do
    {:ok, post} =
      Content.create_post(%{
        slug: "test-post",
        title: "Original Post",
        html_content: "<p>Original content</p>",
        is_public: true,
        author_id: user.id,
        server_id: server.id
      })

    conn = put(conn, "/api/posts/#{post.id}", @update_attrs)
    resp = json_response(conn, 200)
    assert resp["title"] == "Updated Post"
    assert resp["html_content"] == "<p>Updated content</p>"
    assert resp["is_public"] == false
    # Slug should remain unchanged
    assert resp["slug"] == "test-post"
  end

  test "DELETE /api/posts/:id deletes post", %{conn: conn, user: user, server: server} do
    {:ok, post} =
      Content.create_post(%{
        slug: "test-post",
        title: "Test Post",
        html_content: "<p>Content</p>",
        is_public: true,
        author_id: user.id,
        server_id: server.id
      })

    conn = delete(conn, "/api/posts/#{post.id}")
    assert response(conn, 204)
    assert_raise Ecto.NoResultsError, fn -> Content.get_post!(post.id) end
  end
end
