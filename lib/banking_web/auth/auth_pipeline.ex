defmodule Banking.AuthPipeline do
  use Guardian.Plug.Pipeline,
    otp_app: :banking,
    error_handler: Banking.AuthErrorHandler,
    module: Banking.Guardian

    plug Guardian.Plug.VerifyHeader, claims: %{"typ" => "access"}, realm: "Bearer"
    plug Guardian.Plug.EnsureAuthenticated
    plug Guardian.Plug.LoadResource
end
