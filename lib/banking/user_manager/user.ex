defmodule Banking.UserManager.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :balance, :float
    field :password, :string
    field :username, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :balance])
    |> validate_required([:username, :password, :balance])
  end
end
