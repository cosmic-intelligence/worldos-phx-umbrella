defmodule Core.ContentTest do
  use Core.DataCase, async: true

  alias Core.{Accounts, Servers, Content}
  alias Core.Content.Post

  setup do
    {:ok, user} =
      Accounts.create_user(%{
        username: "author",
        email: "author@example.com",
        hashed_password: "hash"
      })

    {:ok, server} = Servers.create_server(%{name: "Srv", owner_id: user.id})
    {:ok, user: user, server: server}
  end

  test "create_post/1", %{user: user, server: srv} do
    {:ok, post} =
      Content.create_post(%{
        slug: "first-post",
        title: "First Post",
        html_content: "<p>Hello</p>",
        server_id: srv.id,
        author_id: user.id,
        is_public: true
      })

    assert %Post{} = Content.get_post!(post.id)
    assert post.slug == "first-post"
  end
end
