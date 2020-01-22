defmodule BankingWeb.UserView do
  use BankingWeb, :view

  def render("user.json",%{user: user}) do
    %{
      id: user.id,
      username: user.username,
      balance_in_cents: user.balance_in_cents,
      email: user.email
    }
  end
end
