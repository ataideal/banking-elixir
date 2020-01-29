defmodule Banking.AuthPipeline do
  @moduledoc """
  Pipeline to authenticated routes, make sure request have a token,
  verify it, and load subject from database to Conn
  """

  use Guardian.Plug.Pipeline,
    otp_app: :banking,
    error_handler: Banking.AuthErrorHandler,
    module: Banking.Guardian

  plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}, realm: "Bearer"
  plug Guardian.Plug.EnsureAuthenticated
  plug Guardian.Plug.LoadResource
end
