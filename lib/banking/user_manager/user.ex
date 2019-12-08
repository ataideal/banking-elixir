defmodule Banking.UserManager.User do
  use Ecto.Schema
  import Ecto.Changeset
  alias Banking.BankTransactions.Transaction

  schema "users" do
    field :balance, :float, default: 1.0e3
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
    |> cast(attrs, [:username, :password, :email, :balance])
    |> validate_required([:username, :password, :email])
    |> unique_constraint(:username)
    |> validate_balance(attrs)
  end

  def validate_balance(changeset, attrs) do
    if (Map.has_key?(attrs, :balance) && attrs.balance < 0), do: add_error(changeset, :balance, "Can not be negative"), else: changeset
  end

end
