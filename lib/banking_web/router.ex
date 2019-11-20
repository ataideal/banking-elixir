defmodule BankingWeb.Router do
  use BankingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end
  pipeline :ensure_auth do
    plug Guardian.Plug.EnsureAuthenticated
  end

  scope "/api/auth", BankingWeb do
    pipe_through :api
    post "/login", AuthenticationController, :login
    post "/signup", AuthenticationController, :signup
  end

  scope "/api", BankingWeb do
    pipe_through [:api, :ensure_auth]
  end
end
