defmodule Banking.AuthErrorHandler do
  @moduledoc """
  Implementation of Guardian ErrorHandler, contains logic for handle errors
  in authentication users
  """
  import Plug.Conn
  use Phoenix.Controller

  @behaviour Guardian.Plug.ErrorHandler

  @impl Guardian.Plug.ErrorHandler
  def auth_error(conn, {type, _reason}, _opts) do
    conn
    |> put_req_header("content-type", "application/json")
    |> put_status(401)
    |> json(%{message: to_string(type)})
  end
end
