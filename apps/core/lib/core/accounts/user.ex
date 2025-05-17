defmodule Core.Accounts.User do
  @moduledoc """
  The User schema represents a registered account in the platform.
  """
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "users" do
    field :username, :string
    field :email, :string
    field :hashed_password, :string

    timestamps()
  end

  @doc """
  A changeset for user registration.
  It hashes the password outside of this function so it can be called from multiple contexts.
  """
  def registration_changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email, :hashed_password])
    |> validate_required([:username, :email, :hashed_password])
    |> validate_length(:username, min: 3, max: 32)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :email])
    |> validate_required([:username, :email])
    |> validate_length(:username, min: 3, max: 32)
    |> validate_format(:email, ~r/^[^\s]+@[^\s]+$/)
    |> unique_constraint(:username)
    |> unique_constraint(:email)
  end
end
