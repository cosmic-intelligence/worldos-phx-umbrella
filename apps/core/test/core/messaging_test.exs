defmodule Core.MessagingTest do
  use Core.DataCase, async: true

  alias Core.{Accounts, Servers, Messaging}
  alias Core.Messaging.Message

  setup do
    {:ok, user} =
      Accounts.create_user(%{
        username: "user1",
        email: "user1@example.com",
        hashed_password: "hash"
      })

    {:ok, server} = Servers.create_server(%{name: "Srv", owner_id: user.id})
    {:ok, channel} = Servers.create_channel(%{name: "gen", server_id: server.id})

    {:ok, user: user, channel: channel}
  end

  test "create_message/1", %{user: user, channel: channel} do
    {:ok, msg} =
      Messaging.create_message(%{content: "hello", channel_id: channel.id, author_id: user.id})

    assert %Message{} = Messaging.get_message!(msg.id)
    assert msg.content == "hello"
  end
end
