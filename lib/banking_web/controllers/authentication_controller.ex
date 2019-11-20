defmodule BankingWeb.AuthenticationController do
  use BankingWeb, :controller

  alias Banking.UserManager
  alias Banking.UserManager.User
  action_fallback BankingWeb.FallbackController

  def login(conn, %{"username" => username, "password" => password}) do
    UserManager.authenticate_user(username, password)
    |> login_reply(conn)
  end

  def signup(conn, %{"user" => user) do
    with %User{} -> UserManager.create_user(user) do
      conn
      |> put_status(:created)
      |> render("user.json", user: user)
    end
  end


  def login_reply({:ok, token, %User{} = user}, conn) do
    conn
    |> put_status(:ok)
    |> render("user_with_token.json", user: user, token: token)
  end

  def login_reply({:error, _reason}, conn) do
    conn
    |> put_status(:unauthorized)
    |> render("error.json", error: "Can not login with these credentials")
  end
end
