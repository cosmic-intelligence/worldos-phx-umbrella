defmodule GatewayWeb.UsersController do
  use GatewayWeb, :controller

  alias Core.Accounts
  alias GatewayWeb.ControllerHelpers, as: Helpers

  @doc """
  GET /api/users/:id
  Returns a user by id.
  """
  def show(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)

    json(conn, %{id: user.id, username: user.username, email: user.email})
  end

  @doc """
  POST /api/users
  Body params: {"username", "email", "password"}
  Creates a new user and returns it.
  """
  def create(conn, params) do
    attrs = %{
      username: Map.get(params, "username"),
      email: Map.get(params, "email"),
      hashed_password: Map.get(params, "password")
    }

    case Accounts.create_user(attrs) do
      {:ok, user} ->
        conn
        |> put_status(:created)
        |> json(%{id: user.id, username: user.username, email: user.email})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{errors: translate_errors(changeset)})
    end
  end

  @doc """
  GET /api/users
  Returns list of users.
  """
  def index(conn, _params) do
    users = Accounts.list_users()
    json(conn, Enum.map(users, &serialize_user/1))
  end

  @doc """
  PUT/PATCH /api/users/:id
  Updates a user (username/email).
  """
  def update(conn, %{"id" => id} = params) do
    user = Accounts.get_user!(id)
    attrs = Map.take(params, ["username", "email"])

    case Accounts.update_user(user, attrs) do
      {:ok, user} ->
        json(conn, serialize_user(user))

      {:error, cs} ->
        conn |> put_status(:unprocessable_entity) |> json(%{errors: Helpers.translate_errors(cs)})
    end
  end

  @doc """
  DELETE /api/users/:id
  Deletes the user.
  """
  def delete(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    {:ok, _} = Accounts.delete_user(user)
    send_resp(conn, :no_content, "")
  end

  defp serialize_user(user), do: %{id: user.id, username: user.username, email: user.email}

  defp translate_errors(cs), do: Helpers.translate_errors(cs)
end
