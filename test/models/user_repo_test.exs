defmodule Rumbl.UserRepoTest do
  use Rumbl.ModelCase
  alias Rumbl.User

  @valid_attrs %{name: "The test", username: "dontfailplease"}

  test "converts unique constraint on username to error" do
    insert_user(%{username: "Sportsman"})
    attrs = Map.put(@valid_attrs, :username, "Sportsman")
    changeset = User.changeset %User{}, attrs

    assert {:error, changeset} = Rumbl.Repo.insert changeset
    assert {:username, {"has already been taken", []}} in changeset.errors
  end
end