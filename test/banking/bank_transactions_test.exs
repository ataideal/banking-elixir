defmodule Banking.BankTransactionsTest do
  use Banking.DataCase

  alias Banking.BankTransactions

  describe "transactions" do
    alias Banking.BankTransactions.Transaction

    @valid_attrs %{transaction_type: 42, value: 120.5}
    @update_attrs %{transaction_type: 43, value: 456.7}
    @invalid_attrs %{transaction_type: nil, value: nil}

    def transaction_fixture(attrs \\ %{}) do
      {:ok, transaction} =
        attrs
        |> Enum.into(@valid_attrs)
        |> BankTransactions.create_transaction()

      transaction
    end

    test "list_transactions/0 returns all transactions" do
      transaction = transaction_fixture()
      assert BankTransactions.list_transactions() == [transaction]
    end

    test "get_transaction!/1 returns the transaction with given id" do
      transaction = transaction_fixture()
      assert BankTransactions.get_transaction!(transaction.id) == transaction
    end

    test "create_transaction/1 with valid data creates a transaction" do
      assert {:ok, %Transaction{} = transaction} = BankTransactions.create_transaction(@valid_attrs)
      assert transaction.transaction_type == 42
      assert transaction.value == 120.5
    end

    test "create_transaction/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = BankTransactions.create_transaction(@invalid_attrs)
    end

    test "update_transaction/2 with valid data updates the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{} = transaction} = BankTransactions.update_transaction(transaction, @update_attrs)
      assert transaction.transaction_type == 43
      assert transaction.value == 456.7
    end

    test "update_transaction/2 with invalid data returns error changeset" do
      transaction = transaction_fixture()
      assert {:error, %Ecto.Changeset{}} = BankTransactions.update_transaction(transaction, @invalid_attrs)
      assert transaction == BankTransactions.get_transaction!(transaction.id)
    end

    test "delete_transaction/1 deletes the transaction" do
      transaction = transaction_fixture()
      assert {:ok, %Transaction{}} = BankTransactions.delete_transaction(transaction)
      assert_raise Ecto.NoResultsError, fn -> BankTransactions.get_transaction!(transaction.id) end
    end

    test "change_transaction/1 returns a transaction changeset" do
      transaction = transaction_fixture()
      assert %Ecto.Changeset{} = BankTransactions.change_transaction(transaction)
    end
  end
end
