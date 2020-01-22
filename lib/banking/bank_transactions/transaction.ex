defmodule Banking.BankTransactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Banking.UserManager.User

  schema "transactions" do
    field :transaction_type, :integer
    field :value_in_cents, :integer
    belongs_to :user_from, User
    belongs_to :user_to, User

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:value_in_cents, :transaction_type, :user_from_id, :user_to_id])
    |> validate_required([:value_in_cents, :transaction_type, :user_from_id])
    |> validate_transaction_rules()
  end

  defp validate_transaction_rules(changeset) do
    value_in_cents = get_change(changeset, :value_in_cents)
    changeset =
      if value_in_cents && value_in_cents <= 0 do
        add_error(changeset, :value_in_cents, "Must to be positive")
      else
        changeset
      end

    transaction_type = get_change(changeset, :transaction_type)
    changeset =
      if not Enum.member?(0..1, transaction_type) do
        add_error(changeset, :transaction_type, "Must be valid")
      else
        changeset
      end

    user_from_id = get_change(changeset, :user_from_id)
    user_to_id = get_change(changeset, :user_to_id)

    cond do
      transaction_type == 1 && user_from_id == user_to_id ->
        add_error(changeset, :user_to, "Can not be yourself")
      true ->
        changeset
    end
  end
end
