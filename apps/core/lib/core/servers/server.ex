defmodule Core.Servers.Server do
  @moduledoc """
  Represents a world/server which groups channels, posts, etc.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "servers" do
    field :name, :string
    field :is_public, :boolean, default: true

    belongs_to :owner, Core.Accounts.User, type: :binary_id, foreign_key: :owner_id

    timestamps(inserted_at: :inserted_at, updated_at: false)
  end

  @doc false
  def changeset(server, attrs) do
    server
    |> cast(attrs, [:name, :is_public, :owner_id])
    |> validate_required([:name, :owner_id])
    |> validate_length(:name, min: 1, max: 100)
  end
end
