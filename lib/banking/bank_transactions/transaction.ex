defmodule Banking.BankTransactions.Transaction do
  use Ecto.Schema
  import Ecto.Changeset
  alias Banking.UserManager.User

  schema "transactions" do
    field :transaction_type, :integer
    field :value, :float
    belongs_to :user_from, User
    belongs_to :user_to, User

    timestamps()
  end

  @doc false
  def changeset(transaction, attrs) do
    transaction
    |> cast(attrs, [:value, :transaction_type, :user_from_id, :user_to_id])
    |> validate_required([:value, :transaction_type, :user_from_id])
    |> validate_transaction_rules(attrs)
  end

  defp validate_transaction_rules(changeset, attrs) do
    changeset = if attrs.value <= 0, do: add_error(changeset, :value, "Must to be positive"), else: changeset
    changeset = if not Enum.member?(0..1,attrs.transaction_type), do: add_error(changeset, :transaction_type, "Must be valid"), else: changeset
    if (attrs.transaction_type == 1 && attrs.user_from_id == attrs.user_to_id) do 
      add_error(changeset, :user_to, "Must be diferent")
    else
      changeset
    end
  end

end
