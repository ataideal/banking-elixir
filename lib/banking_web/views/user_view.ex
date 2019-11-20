defmodule BankingWeb.UserView do
  use BankingWeb, :view

  def render("user.json",%{user: user}) do
    %{
      id: user.id,
      username: user.username,
      balance: user.balance
    }
  end

  def render("user_with_token.json", %{user: user, token: token}) do
    %{
      user: render("user.json", %{user: user}),
      token: token
    }
  end
end
