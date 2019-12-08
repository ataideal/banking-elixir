defmodule BankingWeb.BackofficeController do
  use BankingWeb, :controller

  alias Banking.BankTransactions

  action_fallback BankingWeb.FallbackController

  def backoffice(conn, params) do
    group = params["group"] || nil
    transactions = BankTransactions.transactions_by_group(group)
    conn
    |> put_status(:ok)
    |> json(transactions)
  end
end
