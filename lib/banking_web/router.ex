defmodule BankingWeb.Router do
  use BankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug Banking.AuthPipeline
  end


  scope "/api" do
    pipe_through :api
    scope "/auth", BankingWeb do
      post "/login", AuthenticationController, :login
      post "/signup", AuthenticationController, :signup
    end

    scope "/", BankingWeb do
      pipe_through :authenticated
      post "/withdraw", TransactionController, :withdraw
      post "/transfer", TransactionController, :transfer
    end

    get "/backoffice", BankingWeb.BackofficeController, :backoffice

  end

end
