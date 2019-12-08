defmodule BankingWeb.Router do
  use BankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug Banking.AuthPipeline
  end

  scope "/api/auth", BankingWeb do
    pipe_through :api
    post "/login", AuthenticationController, :login
    post "/signup", AuthenticationController, :signup
    get "/backoffice", BackofficeController, :backoffice
  end

  scope "/api", BankingWeb do
    pipe_through [:api, :authenticated]
    post "/withdraw", TransactionController, :withdraw
    post "/transfer", TransactionController, :transfer
  end
end
