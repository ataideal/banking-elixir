defmodule Banking.UserManager.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :balance, :float, default: 1.0e3
    field :password, :string
    field :username, :string
    field :email, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :email])
    |> validate_required([:username, :password, :email])
    |> unique_constraint(:username)
  end

end
