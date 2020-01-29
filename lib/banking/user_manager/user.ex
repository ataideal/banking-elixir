defmodule Banking.UserManager.User do
  @moduledoc """
  User model to solve banking problem with needed validations
  """
  use Ecto.Schema
  import Ecto.Changeset
  alias Banking.BankTransactions.Transaction

  schema "users" do
    field :balance_in_cents, :integer, default: 100_000
    field :password, :string
    field :username, :string
    field :email, :string
    has_many :my_transactions, Transaction, foreign_key: :user_from_id
    has_many :transactions_to_me, Transaction, foreign_key: :user_to_id

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:username, :password, :email, :balance_in_cents])
    |> validate_required([:username, :password, :email])
    |> unique_constraint(:username)
    |> validate_balance()
    |> put_password_hash()
  end

  defp validate_balance(changeset) do
    balance_in_cents = get_change(changeset, :balance_in_cents)
    if balance_in_cents < 0 do
      add_error(changeset, :balance_in_cents, "Can not be negative")
    else
      changeset
    end
  end

  defp put_password_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
    change(changeset, password: Argon2.hash_pwd_salt(password))
  end

  defp put_password_hash(changeset), do: changeset

end
