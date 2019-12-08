defmodule BankingWeb.AuthenticationView do
  use BankingWeb, :view
  alias BankingWeb.UserView

  def render("user_with_token.json", %{user: user, token: token}) do
    %{
      user: render_one(user, UserView, "user.json"),
      token: token
    }
  end
end
