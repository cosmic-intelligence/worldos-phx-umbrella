defmodule GatewayWeb.UsersControllerTest do
  use GatewayWeb.ConnCase, async: true

  alias Core.Accounts

  @valid_attrs %{username: "tester", email: "tester@example.com", password: "secret"}

  defp create_user_fixture() do
    {:ok, user} =
      Accounts.create_user(%{
        username: "tester",
        email: "tester@example.com",
        hashed_password: "secret"
      })

    user
  end

  test "POST /api/users creates a user", %{conn: conn} do
    conn = post(conn, "/api/users", @valid_attrs)

    assert %{"id" => id, "username" => "tester", "email" => "tester@example.com"} =
             json_response(conn, 201)

    assert Accounts.get_user!(id).email == "tester@example.com"
  end

  test "GET /api/users lists users", %{conn: conn} do
    user = create_user_fixture()

    conn = get(conn, "/api/users")
    list = json_response(conn, 200)
    assert Enum.any?(list, fn %{"id" => id} -> id == user.id end)
  end
end
