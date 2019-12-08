defmodule BankingWeb.UserView do
  use BankingWeb, :view
  alias BankingWeb.UserView

  def render("user.json",%{user: user}) do
    %{
      id: user.id,
      username: user.username,
      balance: user.balance
    }
  end
end
