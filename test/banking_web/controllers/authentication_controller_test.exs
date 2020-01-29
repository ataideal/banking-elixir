defmodule BankingWeb.AuthenticationControllerTest do
  use BankingWeb.ConnCase

  alias Banking.UserManager

  @valid_attrs_user %{email: "some@email.com", password: "some password", username: "some username"}

  describe "POST login/2" do
    setup [:create_user]
    test "when successfuly login, respond with token", %{conn: conn, user: user} do
      params = %{"username" => user.username, "password" => @valid_attrs_user.password}
      response =
        conn
        |> post(Routes.authentication_path(conn, :login), params)
        |> json_response(200)

      expected_user = %{
        "balance_in_cents" => 100_000,
        "email" => @valid_attrs_user.email,
        "id" => user.id,
        "username" => @valid_attrs_user.username
      }

      assert response["user"] == expected_user
      refute response["token"] == nil
    end

    test "when failed login, respond with errors", %{conn: conn, user: user} do
      params = %{"username" => user.username, "password" => "invalid"}
      response =
        conn
        |> post(Routes.authentication_path(conn, :login), params)
        |> json_response(401)

      expected_error = %{
        "errors" => "Can not login with these credentials"
      }

      refute response["errors"] == nil
      assert response == expected_error
    end
  end

  describe "POST signup/2" do
    test "when successfuly signup, respond with user", %{conn: conn} do
      params = %{
        "user" => %{
          "username" => @valid_attrs_user.username,
          "password" => @valid_attrs_user.password,
          "email" => @valid_attrs_user.email
        }
      }
      response =
        conn
        |> post(Routes.authentication_path(conn, :signup), params)
        |> json_response(201)

      user = UserManager.get_last_user()

      expected_user = %{
        "balance_in_cents" => user.balance_in_cents,
        "email" => user.email,
        "id" => user.id,
        "username" => user.username
      }

      assert response == expected_user
    end

    test "when failed signup, respond with errors", %{conn: conn} do
      params = %{
        "user" => %{
          "username" => @valid_attrs_user.username,
          "email" => @valid_attrs_user.email
        }
      }
      response =
        conn
        |> post(Routes.authentication_path(conn, :signup), params)
        |> json_response(422)

      refute response["errors"] == nil
    end
  end

  defp create_user(_) do
    {:ok, user} = UserManager.create_user(@valid_attrs_user)
    {:ok, user: user}
  end
end
