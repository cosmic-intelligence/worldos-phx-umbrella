defmodule Core.Servers.Membership do
  @moduledoc """
  Join table linking users and servers with a role.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  @foreign_key_type :binary_id

  schema "memberships" do
    field :role, :integer, default: 0
    field :joined_at, :utc_datetime_usec

    belongs_to :user, Core.Accounts.User, type: :binary_id, primary_key: true
    belongs_to :server, Core.Servers.Server, type: :binary_id, primary_key: true
  end

  @doc false
  def changeset(membership, attrs) do
    membership
    |> cast(attrs, [:role, :joined_at, :user_id, :server_id])
    |> validate_required([:role, :user_id, :server_id])
  end
end
