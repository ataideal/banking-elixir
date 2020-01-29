defmodule Banking.BackofficeTest do
  use Banking.DataCase

  alias Banking.BankTransactions
  alias Banking.UserManager

  describe "backoffice" do

    @valid_attrs_transaction %{transaction_type: 0, value_in_cents: 12_050}
    @valid_attrs_user %{email: "some@email.com", password: "some password", username: "some username"}

    def transaction_fixture(attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(@valid_attrs_transaction)
        |> BankTransactions.create_transaction()

      transaction
    end

    def user_fixture(attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(@valid_attrs_user)
        |> UserManager.create_user()

      user
    end

    test "transactions_by_group/1 year backoffice" do
      user_from = user_fixture(%{username: "user_from"})
      transaction = transaction_fixture(%{user_from_id: user_from.id})
      transactions_by_year = Banking.transactions_by_group("year")
      assert length(transactions_by_year) == 1
      first_entry = List.first(transactions_by_year)
      assert first_entry.year == transaction.inserted_at.year
      assert first_entry.total_transactions == transaction.value_in_cents
    end

    test "transactions_by_group/1 month backoffice" do
      user_from = user_fixture(%{username: "user_from"})
      transaction = transaction_fixture(%{user_from_id: user_from.id})
      transactions_by_month = Banking.transactions_by_group("month")
      assert length(transactions_by_month) == 1
      first_entry = List.first(transactions_by_month)
      assert first_entry.month == transaction.inserted_at.month
      assert first_entry.year == transaction.inserted_at.year
      assert first_entry.total_transactions == transaction.value_in_cents
    end

    test "transactions_by_group/1 day backoffice" do
      user_from = user_fixture(%{username: "user_from"})
      transaction = transaction_fixture(%{user_from_id: user_from.id})
      transactions_by_day = Banking.transactions_by_group("day")
      assert length(transactions_by_day) == 1
      first_entry = List.first(transactions_by_day)
      assert first_entry.day == transaction.inserted_at.day
      assert first_entry.month == transaction.inserted_at.month
      assert first_entry.year == transaction.inserted_at.year
      assert first_entry.total_transactions == transaction.value_in_cents
    end

    test "transactions_by_group/1 alltime backoffice" do
      user_from = user_fixture(%{username: "user_from"})
      transaction = transaction_fixture(%{user_from_id: user_from.id})
      transactions_all_time = Banking.transactions_by_group("")
      assert length(transactions_all_time) == 1
      first_entry = List.first(transactions_all_time)
      assert first_entry.total_transactions == transaction.value_in_cents
    end

  end
end
