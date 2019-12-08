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
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """

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
    new_balance = user.balance - transaction.value
    with {:error, _} <- UserManager.update_user(user, %{balance: new_balance }) do
      Repo.rollback("User without funds")
    end
  end

  defp transfer_money(transaction) do
    withdraw_money(transaction)
    user = transaction.user_to
    new_balance = user.balance + transaction.value
    with {:error, _} <- UserManager.update_user(user, %{balance: new_balance}) do
      Repo.rollback("User can not receive funds")
    end
  end

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

  def transactions_by_group("month"), do: Repo.all(transactions_by_month())
  def transactions_by_group("year"), do: Repo.all(transactions_by_year())
  def transactions_by_group("day"), do: Repo.all(transactions_by_day())
  def transactions_by_group(_), do: Repo.all(transactions_all_time())

  defp transactions_by_month() do
    from t in Transaction,
    select: %{total_transactions: sum(t.value),
              year: fragment("date_part('year', ?)",t.inserted_at),
              month: fragment("date_part('month', ?)",t.inserted_at)},
    group_by: [fragment("date_part('month', ?)", t.inserted_at),
              fragment("date_part('year', ?)", t.inserted_at)],
    order_by: [fragment("date_part('year', ?) ASC", t.inserted_at),
              fragment("date_part('month', ?) ASC", t.inserted_at)]
  end

  defp transactions_by_year() do
    from t in Transaction,
    select: %{total_transactions: sum(t.value),
              year: fragment("date_part('year', ?)",t.inserted_at)},
    group_by: [fragment("date_part('year', ?)", t.inserted_at)],
    order_by: [fragment("date_part('year', ?) ASC", t.inserted_at)]
  end

  defp transactions_by_day() do
    from t in Transaction,
    select: %{total_transactions: sum(t.value),
              day: fragment("date_part('day', ?)",t.inserted_at),
              month: fragment("date_part('month', ?)",t.inserted_at),
              year: fragment("date_part('year', ?)",t.inserted_at)},
    group_by: [fragment("date_part('day', ?)", t.inserted_at),
              fragment("date_part('month', ?)", t.inserted_at),
              fragment("date_part('year', ?)", t.inserted_at)],
    order_by: [fragment("date_part('year', ?) ASC", t.inserted_at),
              fragment("date_part('month', ?) ASC", t.inserted_at),
              fragment("date_part('day', ?) ASC", t.inserted_at)]
  end

  defp transactions_all_time() do
    from t in Transaction,
    select: %{total_transactions: sum(t.value)}
  end

end
