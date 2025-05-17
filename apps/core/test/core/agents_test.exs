defmodule Core.AgentsTest do
  use Core.DataCase, async: true

  alias Core.{Accounts, Servers, Agents, Messaging}
  alias Core.Agents.{AiAgent, AgentMessage}

  setup do
    {:ok, user} =
      Accounts.create_user(%{
        username: "creator",
        email: "creator@example.com",
        hashed_password: "hash"
      })

    {:ok, srv} = Servers.create_server(%{name: "Srv", owner_id: user.id})
    {:ok, ch} = Servers.create_channel(%{name: "gen", server_id: srv.id})
    {:ok, user: user, server: srv, channel: ch}
  end

  test "create_ai_agent/1", %{user: user, server: srv} do
    {:ok, agent} =
      Agents.create_ai_agent(%{
        name: "Bot",
        config: %{"foo" => "bar"},
        server_id: srv.id,
        creator_id: user.id
      })

    assert %AiAgent{} = Agents.get_ai_agent!(agent.id)
  end

  test "create_agent_message/1", %{user: user, server: srv, channel: ch} do
    {:ok, agent} =
      Agents.create_ai_agent(%{name: "Bot", config: %{}, server_id: srv.id, creator_id: user.id})

    {:ok, msg} =
      Agents.create_agent_message(%{
        content: "Hello human",
        agent_id: agent.id,
        channel_id: ch.id
      })

    assert %AgentMessage{} = Agents.get_agent_message!(msg.id)
    assert msg.content == "Hello human"
  end
end
