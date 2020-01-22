defmodule Banking do
  @moduledoc """
  Banking keeps the contexts that define your domain
  and business logic.

  Contexts are also responsible for managing your data, regardless
  if it comes from the database, an external API or others.
  """

  import Ecto.Query, warn: false

  alias Banking.Repo
  alias Banking.BankTransactions.Transaction

  @doc """
  Query transactions backoffice by group
  ## Examples

      iex> transactions_by_group("year")
      [
        %{total_transactions: 100.0, year: 2015.0},
        %{total_transactions: 100.0, year: 2016.0}
      ]

      iex> transactions_by_group("month")
      [
        %{total_transactions: 100.0, year: 2015.0, month: 1},
        %{total_transactions: 100.0, year: 2016.0, month: 5}
      ]

      iex> transactions_by_group("day")
      [
        %{total_transactions: 100.0, year: 2015.0, month: 1, day: 5},
        %{total_transactions: 100.0, year: 2016.0, month: 5, day: 10}
      ]

      iex> transactions_by_group(_)
      %{total_transactions: 200.0}
  """
  def transactions_by_group("month"), do: Repo.all(transactions_by_month())
  def transactions_by_group("year"), do: Repo.all(transactions_by_year())
  def transactions_by_group("day"), do: Repo.all(transactions_by_day())
  def transactions_by_group(_), do: Repo.all(transactions_all_time())

  defp transactions_by_month() do
    from t in Transaction,
    select: %{total_transactions: sum(t.value_in_cents),
              year: fragment("date_part('year', ?)",t.inserted_at),
              month: fragment("date_part('month', ?)",t.inserted_at)},
    group_by: [fragment("date_part('month', ?)", t.inserted_at),
              fragment("date_part('year', ?)", t.inserted_at)],
    order_by: [fragment("date_part('year', ?) ASC", t.inserted_at),
              fragment("date_part('month', ?) ASC", t.inserted_at)]
  end

  defp transactions_by_year() do
    from t in Transaction,
    select: %{total_transactions: sum(t.value_in_cents),
              year: fragment("date_part('year', ?)",t.inserted_at)},
    group_by: [fragment("date_part('year', ?)", t.inserted_at)],
    order_by: [fragment("date_part('year', ?) ASC", t.inserted_at)]
  end

  defp transactions_by_day() do
    from t in Transaction,
    select: %{total_transactions: sum(t.value_in_cents),
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
    select: %{total_transactions: sum(t.value_in_cents)}
  end
end
