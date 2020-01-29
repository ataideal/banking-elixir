defmodule BankingWeb.TransactionView do
  use BankingWeb, :view
  alias BankingWeb.UserView

  def render("transaction.json", %{transaction: transaction}) do
    %{
      id: transaction.id,
      value_in_cents: transaction.value_in_cents,
      transaction_type: enum_transaction_type(transaction.transaction_type),
      user_from: render_one(transaction.user_from, UserView, "user.json"),
      user_to: render_one(transaction.user_to, UserView, "user.json"),
    }
  end

  defp enum_transaction_type(0), do: "Withdraw"
  defp enum_transaction_type(1), do: "Transfer"
end
