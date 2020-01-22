defmodule BankingWeb.TransactionControllerTest do
  use BankingWeb.ConnCase

  alias Banking.UserManager
  alias Banking.BankTransactions

  @valid_attrs_user %{email: "some@email.com", password: "some password", username: "some username"}
  @valid_attrs_transaction %{value_in_cents: 1000}

  describe "POST withdraw/2" do
    setup [:create_user, :get_token]
    test "when successfuly withdraw, respond with transaction", %{conn: conn, user: user, token: token} do
      params = %{"value_in_cents" => @valid_attrs_transaction.value_in_cents}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transaction_path(conn, :withdraw), params)
        |> json_response(200)

      last_transaction = BankTransactions.get_last_transaction()

      expected_transaction = %{
        "id" => last_transaction.id,
        "transaction_type" => "Withdraw",
        "value_in_cents" => @valid_attrs_transaction.value_in_cents,
        "user_to" => nil,
        "user_from" => %{
          "email" => user.email,
          "id" => user.id,
          "balance_in_cents" => user.balance_in_cents - @valid_attrs_transaction.value_in_cents,
          "username" => user.username
        }
      }

      assert response == expected_transaction
    end

    test "when try to withdraw more than your balance, respond with errors", %{conn: conn, user: user, token: token} do
      params = %{"value_in_cents" => user.balance_in_cents + 1}
      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transaction_path(conn, :withdraw), params)
        |> json_response(422)

      expected_error = %{
        "errors" => "User without funds"
      }

      refute response["errors"] == nil
      assert response == expected_error
    end
  end

  describe "POST transfer/2" do
    setup [:create_user, :get_token]
    @valid_attrs_user_2 %{email: "email@email.com", password: "password", username: "username"}
    test "when successfuly transfer, respond with transaction", %{conn: conn, user: user, token: token} do
      {:ok, user2} = UserManager.create_user(@valid_attrs_user_2)

      params = %{"value_in_cents" => user.balance_in_cents, "username" => user2.username}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transaction_path(conn, :transfer), params)
        |> json_response(200)

      last_transaction = BankTransactions.get_last_transaction()

      expected_transaction = %{
        "id" => last_transaction.id,
        "transaction_type" => "Transfer",
        "value_in_cents" => user.balance_in_cents,
        "user_to" => %{
          "email" => user2.email,
          "id" => user2.id,
          "balance_in_cents" => user2.balance_in_cents + user.balance_in_cents,
          "username" => user2.username
        },
        "user_from" => %{
          "email" => user.email,
          "id" => user.id,
          "balance_in_cents" => 0,
          "username" => user.username
        }
      }

      assert response == expected_transaction
    end

    test "when try to transfer more than your balance, respond with errors", %{conn: conn, user: user, token: token} do
      {:ok, user2} = UserManager.create_user(@valid_attrs_user_2)

      params = %{"value_in_cents" => user.balance_in_cents + 1, "username" => user2.username}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transaction_path(conn, :transfer), params)
        |> json_response(422)

      expected_error = %{
        "errors" => "User without funds"
      }

      refute response["errors"] == nil
      assert response == expected_error
    end

    test "when try to transfer to a not existent username, respond with errors", %{conn: conn, user: user, token: token} do
      params = %{"value_in_cents" => user.balance_in_cents, "username" => "notfound"}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transaction_path(conn, :transfer), params)
        |> json_response(422)

      expected_error = %{
        "errors" => "User not found with this username"
      }

      refute response["errors"] == nil
      assert response == expected_error
    end

    test "when try to transfer to yourself, respond with errors", %{conn: conn, user: user, token: token} do
      params = %{"value_in_cents" => user.balance_in_cents, "username" => user.username}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transaction_path(conn, :transfer), params)
        |> json_response(422)

      expected_error = %{
        "errors" => %{
          "user_to" => ["Can not be yourself"]
        }
      }

      refute response["errors"] == nil
      assert response == expected_error
    end

    test "when try to transfer 0 value_in_cents, respond with errors", %{conn: conn, user: _user, token: token} do
      {:ok, user2} = UserManager.create_user(@valid_attrs_user_2)
      params = %{"value_in_cents" => 0, "username" => user2.username}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transaction_path(conn, :transfer), params)
        |> json_response(422)

      expected_error = %{
        "errors" => %{
          "value_in_cents" => ["Must to be positive"]
        }
      }

      refute response["errors"] == nil
      assert response == expected_error
    end

    test "when try to transfer negative value_in_cents, respond with errors", %{conn: conn, user: _user, token: token} do
      {:ok, user2} = UserManager.create_user(@valid_attrs_user_2)
      params = %{"value_in_cents" => -1, "username" => user2.username}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> post(Routes.transaction_path(conn, :transfer), params)
        |> json_response(422)

      expected_error = %{
        "errors" => %{
          "value_in_cents" => ["Must to be positive"]
        }
      }

      refute response["errors"] == nil
      assert response == expected_error
    end
  end

  defp create_user(_) do
    {:ok, user} = UserManager.create_user(@valid_attrs_user)
    {:ok, user: user}
  end

  defp get_token(%{user: user}) do
    {:ok, token, _} = Banking.Guardian.encode_and_sign(user)
    {:ok, token: token}
  end
end
