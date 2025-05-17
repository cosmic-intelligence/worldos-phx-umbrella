defmodule Core.AccountsTest do
  use Core.DataCase, async: true

  alias Core.Accounts
  alias Core.Accounts.User

  @valid_attrs %{
    username: "tester",
    email: "tester@example.com",
    hashed_password: "hash1234"
  }

  @update_attrs %{
    username: "updated",
    email: "updated@example.com"
  }

  test "create_user/1 with valid data creates a user" do
    assert {:ok, %User{} = user} = Accounts.create_user(@valid_attrs)
    assert user.username == @valid_attrs.username
    assert user.email == @valid_attrs.email
  end

  test "list_users/0 returns all users" do
    {:ok, user} = Accounts.create_user(@valid_attrs)
    assert Accounts.list_users() == [user]
  end

  test "get_user!/1 returns the user with given id" do
    {:ok, user} = Accounts.create_user(@valid_attrs)
    assert Accounts.get_user!(user.id).id == user.id
  end

  test "update_user/2 updates the user" do
    {:ok, user} = Accounts.create_user(@valid_attrs)
    assert {:ok, %User{} = updated} = Accounts.update_user(user, @update_attrs)
    assert updated.username == @update_attrs.username
    assert updated.email == @update_attrs.email
  end

  test "delete_user/1 deletes the user" do
    {:ok, user} = Accounts.create_user(@valid_attrs)
    assert {:ok, %User{}} = Accounts.delete_user(user)
    assert_raise Ecto.NoResultsError, fn -> Accounts.get_user!(user.id) end
  end
end
