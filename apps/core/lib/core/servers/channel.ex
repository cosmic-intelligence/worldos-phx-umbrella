defmodule Core.Servers.Channel do
  @moduledoc """
  Represents a chat channel within a server.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "channels" do
    field :name, :string
    field :is_private, :boolean, default: false
    field :position, :integer, default: 0

    belongs_to :server, Core.Servers.Server, type: :binary_id

    timestamps(updated_at: false)
  end

  @doc false
  def changeset(channel, attrs) do
    channel
    |> cast(attrs, [:name, :is_private, :position, :server_id])
    |> validate_required([:name, :server_id])
    |> validate_length(:name, min: 1, max: 100)
  end
end
