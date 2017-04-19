defmodule Rumbl.TestHelpers do
  alias Rumbl.Repo
  alias Rumbl.User

  def insert_user(attrs \\ %{}) do
    changes = Map.merge(%{
      name: "Test user",
      username: "user#{Base.encode16(:crypto.strong_rand_bytes(8))}",
      password: "testsecret"
    }, attrs)

    %User{}
    |> User.registration_changeset(changes)
    |> Repo.insert!
  end

  def insert_video(user, attrs \\ %{}) do
    user
    |> Ecto.build_assoc(:videos, attrs)
    |> Repo.insert!
  end
end