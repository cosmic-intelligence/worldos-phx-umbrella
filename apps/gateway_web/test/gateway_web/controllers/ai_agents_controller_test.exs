defmodule GatewayWeb.AiAgentsControllerTest do
  use GatewayWeb.ConnCase, async: true

  alias Core.{Accounts, Servers, Agents}

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
    name: "TestBot",
    config: %{
      "model" => "gpt-4",
      "temperature" => 0.7,
      "system_prompt" => "You are a helpful assistant."
    }
  }

  test "POST /api/ai_agents creates an AI agent", %{conn: conn, user: user, server: server} do
    attrs = Map.merge(@create_attrs, %{creator_id: user.id, server_id: server.id})
    conn = post(conn, "/api/ai_agents", attrs)
    resp = json_response(conn, 201)

    assert %{"id" => id, "name" => "TestBot"} = resp
    assert resp["creator_id"] == user.id
    assert resp["server_id"] == server.id
    assert resp["config"]["model"] == "gpt-4"

    assert %Agents.AiAgent{id: ^id} = Agents.get_ai_agent!(id)
  end

  test "GET /api/ai_agents lists AI agents for server", %{conn: conn, user: user, server: server} do
    {:ok, agent} =
      Agents.create_ai_agent(%{
        name: "TestBot",
        config: %{"model" => "gpt-4"},
        creator_id: user.id,
        server_id: server.id
      })

    conn = get(conn, "/api/ai_agents", %{server_id: server.id})
    list = json_response(conn, 200)
    assert Enum.any?(list, fn %{"id" => id} -> id == agent.id end)
  end

  test "GET /api/ai_agents/:id shows AI agent", %{conn: conn, user: user, server: server} do
    {:ok, agent} =
      Agents.create_ai_agent(%{
        name: "TestBot",
        config: %{"model" => "gpt-4"},
        creator_id: user.id,
        server_id: server.id
      })

    conn = get(conn, "/api/ai_agents/#{agent.id}")
    resp = json_response(conn, 200)
    assert resp["id"] == agent.id
    assert resp["name"] == "TestBot"
    assert resp["config"]["model"] == "gpt-4"
    assert resp["creator_id"] == user.id
    assert resp["server_id"] == server.id
  end

  @update_attrs %{
    name: "UpdatedBot",
    config: %{"model" => "gpt-3.5-turbo", "temperature" => 0.5}
  }

  test "PATCH /api/ai_agents/:id updates AI agent", %{conn: conn, user: user, server: server} do
    {:ok, agent} =
      Agents.create_ai_agent(%{
        name: "TestBot",
        config: %{"model" => "gpt-4"},
        creator_id: user.id,
        server_id: server.id
      })

    conn = patch(conn, "/api/ai_agents/#{agent.id}", @update_attrs)
    resp = json_response(conn, 200)
    assert resp["name"] == "UpdatedBot"
    assert resp["config"]["model"] == "gpt-3.5-turbo"
    assert resp["config"]["temperature"] == 0.5
  end

  test "PUT /api/ai_agents/:id updates AI agent", %{conn: conn, user: user, server: server} do
    {:ok, agent} =
      Agents.create_ai_agent(%{
        name: "TestBot",
        config: %{"model" => "gpt-4"},
        creator_id: user.id,
        server_id: server.id
      })

    conn = put(conn, "/api/ai_agents/#{agent.id}", @update_attrs)
    resp = json_response(conn, 200)
    assert resp["name"] == "UpdatedBot"
    assert resp["config"]["model"] == "gpt-3.5-turbo"
    assert resp["config"]["temperature"] == 0.5
  end

  test "DELETE /api/ai_agents/:id deletes AI agent", %{conn: conn, user: user, server: server} do
    {:ok, agent} =
      Agents.create_ai_agent(%{
        name: "TestBot",
        config: %{"model" => "gpt-4"},
        creator_id: user.id,
        server_id: server.id
      })

    conn = delete(conn, "/api/ai_agents/#{agent.id}")
    assert response(conn, 204)
    assert_raise Ecto.NoResultsError, fn -> Agents.get_ai_agent!(agent.id) end
  end
end
