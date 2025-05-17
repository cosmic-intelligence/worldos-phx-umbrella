defmodule Core.ServersTest do
  use Core.DataCase, async: true

  alias Core.Servers
  alias Core.Servers.{Server, Channel, Membership}
  alias Core.Accounts

  setup do
    {:ok, user} =
      Accounts.create_user(%{
        username: "owner",
        email: "owner@example.com",
        hashed_password: "hash"
      })

    {:ok, owner: user}
  end

  describe "servers" do
    test "create_server/1 and list_servers/0", %{owner: owner} do
      {:ok, server} =
        Servers.create_server(%{
          name: "World 1",
          owner_id: owner.id,
          is_public: true
        })

      assert Servers.list_servers() == [server]
      assert %Server{} = Servers.get_server!(server.id)
    end
  end

  describe "channels" do
    setup %{owner: owner} do
      {:ok, server} =
        Servers.create_server(%{name: "Srv", owner_id: owner.id})

      {:ok, server: server}
    end

    test "create_channel/1", %{server: server} do
      {:ok, ch} =
        Servers.create_channel(%{name: "general", server_id: server.id, position: 0})

      assert %Channel{} = Servers.get_channel!(ch.id)
    end
  end

  describe "memberships" do
    setup %{owner: owner} do
      {:ok, server} =
        Servers.create_server(%{name: "Srv", owner_id: owner.id})

      {:ok, server: server}
    end

    test "create_membership/1", %{owner: owner, server: server} do
      {:ok, ms} =
        Servers.create_membership(%{user_id: owner.id, server_id: server.id})

      assert %Membership{} = Servers.get_membership!(owner.id, server.id)
      assert ms.role == 0
    end
  end
end
