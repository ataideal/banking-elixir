defmodule Banking.BankTransactions do
  @moduledoc """
  The BankTransactions context.
  """

  import Ecto.Query, warn: false
  alias Banking.Repo

  alias Banking.BankTransactions.Transaction

  alias Banking.UserManager

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: Repo.get!(Transaction, id) |> Repo.preload([:user_from, :user_to])

  @doc """
  Creates a transaction and execute the transaction inside a Repo.Transaction,
  if some operation went wrong, revert all commits on database.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, errors}

  """

  def get_last_transaction() do
    from(t in Transaction, limit: 1, order_by: [desc: t.id]) |> Repo.one
  end

  def create_transaction(attrs \\ %{}) do
    Repo.transaction(fn ->
      with {:ok, transaction} <- %Transaction{}|> Transaction.changeset(attrs)|> Repo.insert() do
        transaction = Repo.preload(transaction, [:user_from, :user_to])
        case transaction.transaction_type do
          0 -> withdraw_money(transaction)
          1 -> transfer_money(transaction)
        end
        Repo.preload(transaction, [:user_from, :user_to], [force: true])
      else
        {:error, changeset} -> transaction_errors(changeset) |> Repo.rollback()
      end
    end)
  end

  defp withdraw_money(transaction) do
    user = transaction.user_from
    new_balance = user.balance_in_cents - transaction.value_in_cents
    with {:error, _} <- UserManager.update_user(user, %{balance_in_cents: new_balance }) do
      Repo.rollback("User without funds")
    end
  end

  defp transfer_money(transaction) do
    withdraw_money(transaction)
    user = transaction.user_to
    new_balance = user.balance_in_cents + transaction.value_in_cents
    UserManager.update_user(user, %{balance_in_cents: new_balance})
  end

  @doc """
  Traverse transaction changeset errors.
  """
  def transaction_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{source: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction) do
    Transaction.changeset(transaction, %{})
  end

end
