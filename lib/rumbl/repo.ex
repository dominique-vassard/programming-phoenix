defmodule Rumbl.Repo do
  # use Ecto.Repo, otp_app: :rumbl
  @moduledoc """
    In memory repository.
  """

  def all(Rumbl.User) do
    [%Rumbl.User{id: "1",
                 name: "John",
                 username: "johnduff",
                 password: "jd456"},
     %Rumbl.User{id: "2",
                 name: "Jane",
                 username: "janedoe",
                 password: "thisone"},
     %Rumbl.User{id: "3",
                 name: "Jack",
                 username: "jackdaniels",
                 password: "3rdj"}
    ]
  end

  def all(_module), do: []

  def get(module, id) do
    Enum.find all(module), fn map -> map.id == id end
  end

  def get_by(module, params) do
    Enum.find all(module), fn map ->
      Enum.all?(params, fn {key, val} -> Map.get(map, key) == val end)
    end
  end
end
