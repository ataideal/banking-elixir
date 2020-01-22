defmodule Banking.UserManagerTest do
  use Banking.DataCase

  alias Banking.UserManager
  alias Argon2
  describe "users" do
    alias Banking.UserManager.User

    @valid_attrs %{email: "some@email.com", password: "some password", username: "some username"}
    @update_attrs %{balance_in_cents: 45670, email: "some_updated@email.com", password: "some updated password", username: "some updated username"}
    @invalid_attrs %{balance_in_cents: -1, email: "some@email.com", password: "some password", username: "some username"}

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs)
        |> UserManager.create_user()

      user
    end

    test "list_users/0 returns all users" do
      user = user_fixture()
      assert UserManager.list_users() == [user]
    end

    test "get_user!/1 returns the user with given id" do
      user = user_fixture()
      assert UserManager.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      assert {:ok, %User{} = user} = UserManager.create_user(@valid_attrs)
      assert user.balance_in_cents == 100000
      assert user.email == @valid_attrs.email
      assert Argon2.verify_pass(@valid_attrs.password, user.password)
      assert user.username == @valid_attrs.username
    end

    test "create_user/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = UserManager.create_user(@invalid_attrs)
    end

    test "update_user/2 with valid data updates the user" do
      user = user_fixture()
      assert {:ok, %User{} = user} = UserManager.update_user(user, @update_attrs)
      assert user.balance_in_cents == @update_attrs.balance_in_cents
      assert user.email == @update_attrs.email
      assert Argon2.verify_pass(@update_attrs.password, user.password)
      assert user.username == @update_attrs.username
    end

    test "update_user/2 with invalid data returns error changeset" do
      user = user_fixture()
      assert {:error, %Ecto.Changeset{}} = UserManager.update_user(user, @invalid_attrs)
    end

    test "delete_user/1 deletes the user" do
      user = user_fixture()
      assert {:ok, %User{}} = UserManager.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> UserManager.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset" do
      user = user_fixture()
      assert %Ecto.Changeset{} = UserManager.change_user(user)
    end

    test "authenticate_user/2 authenticate with valid credentials" do
      {:ok, user} =  UserManager.create_user(@valid_attrs)
      assert {:ok, token, user_authenticated} = UserManager.authenticate_user(@valid_attrs.username, @valid_attrs.password)
      assert user_authenticated.username == user.username
      assert user_authenticated.email == user.email
      assert user_authenticated.balance_in_cents == user.balance_in_cents
    end

    test "authenticate_user/2 authenticate with invalid username" do
      user = user_fixture()
      assert {:error, :unauthorized} = UserManager.authenticate_user("invalid", user.password)
    end

    test "authenticate_user/2 authenticate with invalid password" do
      user = user_fixture()
      assert {:error, :unauthorized} = UserManager.authenticate_user(user.username, "invalid")
    end

  end
end
