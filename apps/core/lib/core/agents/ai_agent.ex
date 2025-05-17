defmodule Core.Agents.AiAgent do
  @moduledoc """
  Represents an AI agent attached to a server.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "ai_agents" do
    field :name, :string
    field :config, :map

    belongs_to :server, Core.Servers.Server, type: :binary_id
    belongs_to :creator, Core.Accounts.User, type: :binary_id, foreign_key: :creator_id

    timestamps(inserted_at: :inserted_at, updated_at: false)
  end

  def changeset(agent, attrs) do
    agent
    |> cast(attrs, [:name, :config, :server_id, :creator_id])
    |> validate_required([:name, :config, :server_id, :creator_id])
  end
end
