defmodule SamplePhx.AccountsTest do
  use SamplePhx.DataCase, async: true

  alias SamplePhx.Accounts
  alias Accounts.User

  describe "register_user/1" do
    @valid_attrs %{
      name: "User",
      username: "jvalim",
      password: "secret"
    }
    @invalid_attrs %{}

    test "with valid data, inserts user" do
      assert {:ok, %User{id: id} = user} = Accounts.register_user(@valid_attrs)
      assert user.name == "User"
      assert user.username == "jvalim"
      assert [%User{id: ^id}] = Accounts.list_users()
    end

    test "with invalid data, does not insert user" do
      assert {:error, _changeset} = Accounts.register_user(@invalid_attrs)
      assert Accounts.list_users() == []
    end

    test "enforce unique usernames" do
      assert {:ok, %User{id: id}} = Accounts.register_user(@valid_attrs)
      assert {:error, changeset} = Accounts.register_user(@valid_attrs)
      assert %{username: ["has already been taken"]} = errors_on(changeset)
    end

    test "reject long usernames" do
      attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
      {:error, changeset} = Accounts.register_user(attrs)
      assert %{username: ["should be at most 20 character(s)"]} = errors_on(changeset)
      assert Accounts.list_users() == []
    end

    test "requires password to be at least 6 chars long" do
      attrs = Map.put(@valid_attrs, :password, "12345")
      {:error, changeset} = Accounts.register_user(attrs)
      assert %{password: ["should be at least 6 character(s)"]} = errors_on(changeset)
      assert Accounts.list_users() == []
    end
  end

  describe "authenticate_by_username_and_password/2" do
    @password "123456"

    setup do
      {:ok, user: user_fixture(password: @password)}
    end

    test "with correct password, returns user", %{user: user} do
      result = Accounts.authenticate_by_username_and_password(user.username, @password)
      assert {:ok, authenticated_user} = result
      assert authenticated_user.id == user.id
    end

    test "with invalid password, returns unauthenticated error", %{user: user} do
      result = Accounts.authenticate_by_username_and_password(user.username, "badpassword")
      assert {:error, :unauthorized} = result
    end

    test "with unknown username, returns not found error" do
      result = Accounts.authenticate_by_username_and_password("unknownuser", @password)
      assert {:error, :not_found} = result
    end
  end
end
