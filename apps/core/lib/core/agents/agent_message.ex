defmodule Core.Agents.AgentMessage do
  @moduledoc """
  Represents a message produced by an AI agent.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "agent_messages" do
    field :content, :string

    belongs_to :agent, Core.Agents.AiAgent, type: :binary_id
    belongs_to :channel, Core.Servers.Channel, type: :binary_id

    timestamps(inserted_at: :inserted_at, updated_at: false)
  end

  def changeset(am, attrs) do
    am
    |> cast(attrs, [:content, :agent_id, :channel_id])
    |> validate_required([:content, :agent_id, :channel_id])
  end
end
