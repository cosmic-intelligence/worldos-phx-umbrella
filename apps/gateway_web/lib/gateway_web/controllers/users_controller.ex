defmodule GatewayWeb.UsersController do
  use GatewayWeb, :controller

  alias Core.Accounts

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

  # Simple helper to turn changeset errors into a map similar to Phoenix.HTML helpers
  defp translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
