defmodule Rumbl.User do
  use Rumbl.Web, :model


  schema "users" do
    field :name, :string
    field :username, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    has_many :videos, Rumbl.Video

    timestamps()
  end

  @required_fields ~w(name username)
  @sensitive_fields ~w(password)

  @doc """
  General changeset: non-sensitive data
  """
  def changeset(model, params \\ %{}) do
    model
    |> cast(params, @required_fields)
    |> validate_required(Enum.map @required_fields, &String.to_atom/1)
    |> validate_length(:username, min: 5, max: 20)
  end

  @doc """
    Sensitive data changeset
  """
  def registration_changeset(model, params) do
    model
    |> changeset(params)
    |> cast(params, @sensitive_fields)
    |> validate_required(Enum.map @sensitive_fields, &String.to_atom/1)
    |> validate_length(:password, min: 6, max: 20)
    |> put_pass_hash()
  end

  @doc """
    compute password hash from password
  """
  def put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))
      _ ->
        changeset
    end
  end
end