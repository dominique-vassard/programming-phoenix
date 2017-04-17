defmodule Rumbl.User do
  use Rumbl.Web, :model


  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string

    timestamps()
  end

  @required_fields ~w(name username)
  @optional_fields ~w(password)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields ++ @optional_fields)
    |> validate_required(Enum.map @required_fields, &String.to_atom/1)
    |> validate_length(:username, min: 5, max: 20)
  end
end