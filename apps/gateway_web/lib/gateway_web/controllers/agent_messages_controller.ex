defmodule GatewayWeb.AgentMessagesController do
  use GatewayWeb, :controller
  alias Core.Agents
  alias GatewayWeb.ControllerHelpers, as: Helpers

  def index(conn, params) do
    agent_id = Map.get(params, "agent_id")
    json(conn, Enum.map(Agents.list_agent_messages(agent_id), &serialize/1))
  end

  def show(conn, %{"id" => id}) do
    json(conn, serialize(Agents.get_agent_message!(id)))
  end

  def create(conn, params) do
    case Agents.create_agent_message(params) do
      {:ok, m} ->
        conn |> put_status(:created) |> json(serialize(m))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    m = Agents.get_agent_message!(id)

    case Agents.update_agent_message(m, Map.delete(params, "id")) do
      {:ok, m} ->
        json(conn, serialize(m))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    m = Agents.get_agent_message!(id)
    {:ok, _} = Agents.delete_agent_message(m)
    send_resp(conn, :no_content, "")
  end

  defp serialize(m),
    do: %{
      id: m.id,
      content: m.content,
      agent_id: m.agent_id,
      channel_id: m.channel_id,
      inserted_at: m.inserted_at
    }
end
