defmodule Core.Agents do
  @moduledoc """
  Context for AI agents and their messages.
  """
  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Agents.{AiAgent, AgentMessage}

  # Agents ---------------------------------------------------------------
  def list_ai_agents(server_id \\ nil) do
    query = if server_id, do: from(a in AiAgent, where: a.server_id == ^server_id), else: AiAgent
    Repo.all(query)
  end

  def get_ai_agent!(id), do: Repo.get!(AiAgent, id)

  def create_ai_agent(attrs \\ %{}) do
    %AiAgent{}
    |> AiAgent.changeset(attrs)
    |> Repo.insert()
  end

  def update_ai_agent(%AiAgent{} = agent, attrs) do
    agent
    |> AiAgent.changeset(attrs)
    |> Repo.update()
  end

  def delete_ai_agent(%AiAgent{} = agent), do: Repo.delete(agent)

  def change_ai_agent(%AiAgent{} = agent, attrs \\ %{}), do: AiAgent.changeset(agent, attrs)

  # Agent Messages -------------------------------------------------------
  def list_agent_messages(agent_id \\ nil) do
    query =
      if agent_id, do: from(m in AgentMessage, where: m.agent_id == ^agent_id), else: AgentMessage

    Repo.all(query)
  end

  def get_agent_message!(id), do: Repo.get!(AgentMessage, id)

  def create_agent_message(attrs \\ %{}) do
    %AgentMessage{}
    |> AgentMessage.changeset(attrs)
    |> Repo.insert()
  end

  def update_agent_message(%AgentMessage{} = msg, attrs) do
    msg
    |> AgentMessage.changeset(attrs)
    |> Repo.update()
  end

  def delete_agent_message(%AgentMessage{} = msg), do: Repo.delete(msg)

  def change_agent_message(%AgentMessage{} = msg, attrs \\ %{}),
    do: AgentMessage.changeset(msg, attrs)
end
