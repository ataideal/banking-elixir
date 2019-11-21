defmodule BankingWeb.UserView do
  use BankingWeb, :view

  def render("user.json",%{user: user}) do
    %{
      id: user.id,
      username: user.username,
      balance: user.balance
    }
  end
end
