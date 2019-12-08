defmodule BankingWeb.TransactionController do
  use BankingWeb, :controller

  alias Banking.UserManager
  alias Banking.UserManager.User
  alias Banking.BankTransactions
  alias Banking.BankTransactions.Transaction
  alias BankingWeb.UserView
  alias BankingWeb.TransactionView

  action_fallback BankingWeb.FallbackController

  def withdraw(conn, %{"value" => value}) do
    current_user = Guardian.Plug.current_resource(conn)
    transaction_params = %{value: value, user_from_id: current_user.id, transaction_type: 0}
    with {:ok, %Transaction{} = transaction} <- BankTransactions.create_transaction(transaction_params) do
      reply_transaction({:ok, transaction}, conn)
    else
      {:error, reason} -> reply_transaction({:error, reason}, conn)
    end
  end

  def transfer(conn, %{"value" => value, "username" => username}) do
    current_user = Guardian.Plug.current_resource(conn)
    user_to = UserManager.get_user_by_username!(username)
    transaction_params = %{value: value,
                          user_from_id: current_user.id,
                          user_to_id: user_to.id,
                          transaction_type: 1}

    with {:ok, %Transaction{} = transaction} <- BankTransactions.create_transaction(transaction_params) do
      reply_transaction({:ok, transaction}, conn)
    else
      {:error, reason} -> reply_transaction({:error, reason}, conn)
    end
  end

  def backoffice({:ok, token, %User{} = user}, conn) do
    conn
    |> put_status(:ok)
    |> render("user_with_token.json", user: user, token: token)
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
