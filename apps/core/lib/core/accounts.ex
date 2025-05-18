defmodule Core.Accounts do
  @moduledoc """
  The Accounts context.
  """
  import Ecto.Query, warn: false
  alias Core.Repo

  alias Core.Accounts.User

  @doc """
  Returns the list of users.
  """
  def list_users do
    Repo.all(User)
  end

  @doc """
  Gets a single user.
  Raises `Ecto.NoResultsError` if the User does not exist.
  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Creates a user.
  The caller is responsible for providing a hashed password.
  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user.
  """
  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user.
  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.
  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Registers a new user taking raw params that include a plaintext `"password"` key.
  This keeps password/field naming concerns out of web controllers.
  NOTE: For now we do *not* hash the password – the caller was already
  passing plaintext into `hashed_password`. We keep behaviour identical to
  avoid breaking tests, while centralising the logic in one place.
  Add hashing here once authentication is implemented.
  """
  def register_user(%{"username" => u, "email" => e, "password" => p} = _attrs) do
    create_user(%{username: u, email: e, hashed_password: p})
  end

  def register_user(_), do: {:error, :invalid_params}
end
