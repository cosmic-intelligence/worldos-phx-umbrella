defmodule GatewayWeb.AiAgentsController do
  use GatewayWeb, :controller
  alias Core.Agents
  alias GatewayWeb.ControllerHelpers, as: Helpers

  def index(conn, params) do
    server_id = Map.get(params, "server_id")
    json(conn, Enum.map(Agents.list_ai_agents(server_id), &serialize/1))
  end

  def show(conn, %{"id" => id}) do
    json(conn, serialize(Agents.get_ai_agent!(id)))
  end

  def create(conn, params) do
    case Agents.create_ai_agent(params) do
      {:ok, a} ->
        conn |> put_status(:created) |> json(serialize(a))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def update(conn, %{"id" => id} = params) do
    a = Agents.get_ai_agent!(id)

    case Agents.update_ai_agent(a, Map.delete(params, "id")) do
      {:ok, a} ->
        json(conn, serialize(a))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  def delete(conn, %{"id" => id}) do
    a = Agents.get_ai_agent!(id)
    {:ok, _} = Agents.delete_ai_agent(a)
    send_resp(conn, :no_content, "")
  end

  defp serialize(a),
    do: %{
      id: a.id,
      name: a.name,
      config: a.config,
      server_id: a.server_id,
      creator_id: a.creator_id,
      inserted_at: a.inserted_at
    }
end
