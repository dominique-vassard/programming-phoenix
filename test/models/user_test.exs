defmodule Rumbl.UserTest do
  use Rumbl.ModelCase, async: true
  alias Rumbl.User

  @valid_attrs %{name: "A User named test", username: "evatest", password: "secretpass"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = User.changeset(%User{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = User.changeset(%User{}, @invalid_attrs)
    refute changeset.valid?
  end

  test "changeset does not accept long user name" do
    attrs = Map.put(@valid_attrs, :username, String.duplicate("a", 30))
    assert {:username, "should be at most 20 character(s)"} in
    errors_on(%User{}, attrs)
  end

  test "registration_changeset password must be at least 6 chars long" do
    attrs = Map.put(@valid_attrs, :password, "12345")
    changeset = User.registration_changeset(%User{}, attrs)
    assert {:password, {"should be at least %{count} character(s)", [count: 6, validation: :length, min: 6]}}
    in changeset.errors
  end

  test "registration_changeset with valid attributes and hash" do
    changeset = User.registration_changeset %User{}, @valid_attrs
    %{"password": password, "password_hash": hash} = changeset.changes

    assert changeset.valid?
    assert hash
    assert Comeonin.Bcrypt.checkpw password, hash
  end
end