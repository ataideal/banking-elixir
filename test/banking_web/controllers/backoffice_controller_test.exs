defmodule BankingWeb.BackofficeControllerTest do
  use BankingWeb.ConnCase

  alias Banking.UserManager
  alias Banking.BankTransactions

  @valid_attrs_user %{email: "some@email.com", password: "some password", username: "some username"}

  describe "GET backoffice/2" do
    setup [:create_user, :get_token]
    test "when get backoffice of all transactions", %{conn: conn, user: user, token: token} do

      transactions = [%{value_in_cents: 1000, user_from_id: user.id, transaction_type: 0},
                      %{value_in_cents: 2452, user_from_id: user.id, transaction_type: 0}]

      [{:ok, transaction1},{:ok, transaction2}] = Enum.map(transactions, &BankTransactions.create_transaction(&1))

      params = %{}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(Routes.backoffice_path(conn, :backoffice), params)
        |> json_response(200)

      expected = [
        %{"total_transactions" => transaction1.value_in_cents + transaction2.value_in_cents}
      ]

      assert response == expected
    end

    test "when get backoffice by year", %{conn: conn, user: user, token: token} do

      transactions = [%{value_in_cents: 1000, user_from_id: user.id, transaction_type: 0},
                      %{value_in_cents: 2452, user_from_id: user.id, transaction_type: 0}]

      [{:ok, transaction1},{:ok, transaction2}] = Enum.map(transactions, &BankTransactions.create_transaction(&1))

      params = %{"group" => "year"}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(Routes.backoffice_path(conn, :backoffice), params)
        |> json_response(200)

      expected = [
        %{
          "total_transactions" => transaction1.value_in_cents + transaction2.value_in_cents,
          "year" => transaction1.inserted_at.year
        }
      ]
      assert response == expected
    end

    test "when get backoffice by month", %{conn: conn, user: user, token: token} do

      transactions = [%{value_in_cents: 1000, user_from_id: user.id, transaction_type: 0},
                      %{value_in_cents: 2452, user_from_id: user.id, transaction_type: 0}]

      [{:ok, transaction1},{:ok, transaction2}] = Enum.map(transactions, &BankTransactions.create_transaction(&1))

      params = %{"group" => "month"}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(Routes.backoffice_path(conn, :backoffice), params)
        |> json_response(200)

      expected = [
        %{
          "total_transactions" => transaction1.value_in_cents + transaction2.value_in_cents,
          "year" => transaction1.inserted_at.year,
          "month" => transaction2.inserted_at.month
        }
      ]
      assert response == expected
    end

    test "when get backoffice by day", %{conn: conn, user: user, token: token} do

      transactions = [%{value_in_cents: 1000, user_from_id: user.id, transaction_type: 0},
                      %{value_in_cents: 2452, user_from_id: user.id, transaction_type: 0}]

      [{:ok, transaction1},{:ok, transaction2}] = Enum.map(transactions, &BankTransactions.create_transaction(&1))

      params = %{"group" => "day"}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}")
        |> get(Routes.backoffice_path(conn, :backoffice), params)
        |> json_response(200)

      expected = [
        %{
          "total_transactions" => transaction1.value_in_cents + transaction2.value_in_cents,
          "year" => transaction1.inserted_at.year,
          "month" => transaction2.inserted_at.month,
          "day" => transaction2.inserted_at.day
        }
      ]
      assert response == expected
    end

    test "when try to get backoffice without access token", %{conn: conn, user: _user, token: _token} do
      params = %{}

      response =
        conn
        |> get(Routes.backoffice_path(conn, :backoffice), params)
        |> json_response(401)

      expected = %{
        "message" => "unauthenticated"
      }

      assert response == expected
    end

    test "when try to get backoffice with a invalid", %{conn: conn, user: _user, token: token} do
      params = %{}

      response =
        conn
        |> put_req_header("authorization", "Bearer #{token}1111")
        |> get(Routes.backoffice_path(conn, :backoffice), params)
        |> json_response(401)

      expected = %{
        "message" => "invalid_token"
      }

      assert response == expected
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
