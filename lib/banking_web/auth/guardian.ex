defmodule Banking.Guardian do
  @moduledoc """
  Guardian implementation module.
  Generate token claims and verify claims to authentication 
  """
  use Guardian, otp_app: :banking

  alias Banking.UserManager

  def subject_for_token(user, _claims) do
    {:ok, to_string(user.id)}
  end

  def resource_from_claims(%{"sub" => id}) do
    case UserManager.get_user!(id) do
      nil -> {:error, :resource_not_found}
      user -> {:ok, user}
    end
  end
end
