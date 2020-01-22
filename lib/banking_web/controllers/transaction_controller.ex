defmodule BankingWeb.TransactionController do
  use BankingWeb, :controller

  alias Banking.UserManager
  alias Banking.UserManager.User
  alias Banking.BankTransactions
  alias Banking.BankTransactions.Transaction
  alias BankingWeb.TransactionView

  action_fallback BankingWeb.FallbackController

  def withdraw(conn, %{"value_in_cents" => value}) do
    current_user = Guardian.Plug.current_resource(conn)
    transaction_params = %{value_in_cents: value, user_from_id: current_user.id, transaction_type: 0}
    with {:ok, %Transaction{} = transaction} <- BankTransactions.create_transaction(transaction_params) do
      reply_transaction({:ok, transaction}, conn)
    else
      {:error, reason} -> reply_transaction({:error, reason}, conn)
    end
  end

  def transfer(conn, %{"value_in_cents" => value, "username" => username}) do
    current_user = Guardian.Plug.current_resource(conn)
    with %User{} = user_to <- UserManager.get_user_by_username(username) do
      transaction_params = %{value_in_cents: value,
                            user_from_id: current_user.id,
                            user_to_id: user_to.id,
                            transaction_type: 1}

      with {:ok, %Transaction{} = transaction} <- BankTransactions.create_transaction(transaction_params) do
        reply_transaction({:ok, transaction}, conn)
      else
        {:error, reason} -> reply_transaction({:error, reason}, conn)
      end
    else
      nil -> reply_transaction({:error, "User not found with this username"}, conn)
    end
  end

  def reply_transaction({:ok, transaction}, conn) do
    conn
    |> put_status(:ok)
    |> put_view(TransactionView)
    |> render("transaction.json", transaction: transaction)
  end

  def reply_transaction({:error, reason}, conn) do
    conn
    |> put_status(:unprocessable_entity)
    |> json(%{errors: reason})
  end
end
