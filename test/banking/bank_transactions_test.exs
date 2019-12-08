defmodule Banking.BankTransactionsTest do
  use Banking.DataCase

  alias Banking.BankTransactions
  alias Banking.UserManager

  describe "transactions" do
    alias Banking.BankTransactions.Transaction

    @valid_attrs %{transaction_type: 0, value: 120.5}
    @invalid_attrs %{transaction_type: 10, value: nil}

    @valid_attrs_user %{email: "some@email.com", password: "some password", username: "some username"}


    def transaction_fixture(attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(@valid_attrs)
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

    test "get_transaction!/1 returns the transaction with given id" do
      user_from = user_fixture(%{username: "user_from"})
      transaction = transaction_fixture(%{user_from_id: user_from.id})
      assert BankTransactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 withdraw transaction_type" do
      user_from = user_fixture(%{username: "user_from"})
      assert {:ok, %Transaction{} = transaction} =
        Enum.into(%{user_from_id: user_from.id}, @valid_attrs)
        |> BankTransactions.create_transaction()

      assert transaction.transaction_type == 0
      assert transaction.value == 120.5
      assert transaction.user_from.balance == user_from.balance - transaction.value
    end

    test "create_transaction/1 transfer transaction_type" do
      user_from = user_fixture(%{username: "user_from"})
      user_to = user_fixture(%{username: "user_to"})
      assert {:ok, %Transaction{} = transaction} =
        Enum.into(%{user_from_id: user_from.id,
                    user_to_id: user_to.id,
                    transaction_type: 1}, @valid_attrs)
        |> BankTransactions.create_transaction()

      assert transaction.transaction_type == 1
      assert transaction.value == 120.5
      assert transaction.user_from.balance == user_from.balance - transaction.value
      assert transaction.user_to.balance == user_to.balance + transaction.value
    end

    test "create_transaction/1 withdraw transaction_type without enough money" do
      user_from = user_fixture(%{username: "user_from"})
      assert {:error, "User without funds"} =
        Enum.into(%{user_from_id: user_from.id, value: 1000.1}, @valid_attrs)
        |> BankTransactions.create_transaction()
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, _} = BankTransactions.create_transaction(@invalid_attrs)
    end

    test "change_transaction/1 returns a transaction changeset" do
      user_from = user_fixture(%{username: "user_from"})
      transaction = transaction_fixture(%{user_from_id: user_from.id})
      assert %Ecto.Changeset{} = BankTransactions.change_transaction(transaction)
    end
  end
end
