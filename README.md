# Banking

## Development setup:

  * Make sure you have `docker` and `docker-compose` installed.
  * Open the terminal and go to project's root folder.
  * Run on terminal `docker-compose build`.
  * Make sure you're not running process on port `5432`(postgres) or `4000`(phoenix).
  * and then `docker-compose up`.

Now you can use the API on [`localhost:4000`](http://localhost:4000).

## Deployment setup (Heroku):
##### Deploy made by following https://hexdocs.pm/phoenix/heroku.html

  * Create a app on Heroku
  * Add new buildpack `hashnuke/elixir`
  * Add `Heroku Postgres` add-ons
  * On app settings, set your env variables:
    * GUARDIAN_SECRET_KEY: `key`
    * POOL_SIZE: `18`
    * SECRET_KEY_BASE: `another key`
  * On your project file `prod.exs` change url host config to your url app
  * Run on project's root folder: `heroku git:remote -a your-app-name`
  * Commit your changes
  * and then deploy it to heroku: `git heroku push your-branch:master`
  * After deploy finish, run on heroku console: `mix do ecto.create, ecto.migrate`
  * After that you server is ready to be used

Now you can use the API on [`localhost:4000`](http://localhost:4000).

## API Docs:
[![Run in Postman](https://run.pstmn.io/button.svg)](https://app.getpostman.com/run-collection/9cb38f44f42b04feae08#?env%5Bbanking-heroku%5D=W3sia2V5IjoiaG9zdCIsInZhbHVlIjoiaHR0cHM6Ly9lbGl4aXItYmFuay5oZXJva3VhcHAuY29tIiwiZGVzY3JpcHRpb24iOiIiLCJ0eXBlIjoidGV4dCIsImVuYWJsZWQiOnRydWV9LHsia2V5IjoidG9rZW4iLCJ2YWx1ZSI6IiIsImRlc2NyaXB0aW9uIjoiIiwidHlwZSI6InRleHQiLCJlbmFibGVkIjp0cnVlfV0=)

  * You can import the Postman's collection with the link above or access the published version [`here`](https://documenter.getpostman.com/view/2488938/SWE6byNF).

  * The application was deployed on Heroku at https://elixir-bank.herokuapp.com/

#### Auth

  * SignUp:
    * Endpoint: `/api/auth/signup`
    * Method: `POST`
    * Body params:
    ```json
    {
        "user": {
                  "username": "ataideal",
                  "email": "ataide.neto31@gmail.com",
                  "password": "123123"
                }
    }
    ```

    * Response(Success):
    ```json
      {
        "balance": 1000,
        "email": "ataide.neto31@gmail.com",
        "id": 1,
        "username": "ataideal"
      }
    ```

    * Response(Error):
    ```json
    {
        "errors": {
            "username": [
                "has already been taken"
            ]
        }
    }
    ```

  * Login:
    * Endpoint: `/api/auth/login`
    * Method: `POST`
    * Body params:
    ```json
    {
        "username": "ataideal",
        "password": "123123"
    }
    ```

    * Response(Success):
    ```json
      {
        "token": "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJiYW5raW5nIiwiZXhwIjoxNTc4Mzk5NTUxLCJpYXQiOjE1NzU5ODAzNTEsImlzcyI6ImJhbmtpbmciLCJqdGkiOiI1YThkMThhMC02YTNhLTQxNTYtYTE1My03OWJlMDU5MWQzNTkiLCJuYmYiOjE1NzU5ODAzNTAsInN1YiI6IjEiLCJ0eXAiOiJhY2Nlc3MifQ.1wgdaMv-HqG-5LuvO_OSRJbEeBvvrBMUG_AuFWkhOoYxvUhCO7oUDaRVBxXwxqGyMyIBEWjm-mEoMack8aTiQQ",
        "user": {
          "balance": 1000,
          "email": "ataide.neto31@gmail.com",
          "id": 1,
          "username": "ataideal"
      }
    ```

    * Response(Error):
    ```json
    {
        "errors": "Can not login with these credentials"
    }
    ```

#### Transactions

  * Withdraw:
    * Endpoint: `/api/withdraw`
    * Method: `POST`
    * Headers: `Authorization`: Bearer token`
    * Body params:
    ```json
    {
    	"value": 100
    }
    ```

    * Response(Success):
    ```json
      {
        "id": 1,
        "transaction_type": "Withdraw",
        "user_from": {
            "balance": 900,
            "email": "ataide.neto31@gmail.com",
            "id": 1,
            "username": "ataideal"
        },
        "user_to": null,
        "value": 100
      }
    ```

    * Response(Error):
    ```json
    {
        "errors": "User without funds"
    }
    ```

  * Transfer:
    * Endpoint: `/api/transfer`
    * Method: `POST`
    * Headers: `Authorization`: Bearer token`
    * Body params:
    ```json
    {
    	"value": 100,
    	"username": "ataideal"
    }
    ```

    * Response(Success):
    ```json
    {
        "id": 3,
        "transaction_type": "Transfer",
        "user_from": {
            "balance": 800,
            "email": "ataide.neto31@gmail.com",
            "id": 1,
            "username": "ataideal"
        },
        "user_to": {
            "balance": 1100,
            "email": "ataide.neto31@gmail.com",
            "id": 3,
            "username": "ataideal1"
        },
        "value": 100
    }
    ```

    * Response(Error):
    ```json
    {
        "errors": "User without funds"
    }
    ```

    * Response(Error2):
    ```json
    {
        "errors": {
            "user_to": [
                "Must be diferent"
            ],
            "value": [
                "Must to be positive"
            ]
        }
    }
    ```

  #### Backoffice
    * Backoffice transactions:
      * Endpoint: `/api/backoffice`
      * Method: `GET`
      * Url params:
      ```javascript
      group=['year','month', 'day', 'all_time']
      ```
      * Response(Success) `group=year`:
      ```json
        {
            "total_transactions": 100,
            "year": 2015
        },
        {
            "total_transactions": 100,
            "year": 2016
        },
        {
            "total_transactions": 300,
            "year": 2018
        },
        {
            "total_transactions": 16530,
            "year": 2019
        }
      ```
      * Response(Success) `group=month`:
      ```json
      [
          {
              "month": 12,
              "total_transactions": 100,
              "year": 2015
          },

          {
              "month": 12,
              "total_transactions": 100,
              "year": 2018
          },
          {
              "month": 1,
              "total_transactions": 100,
              "year": 2019
          },
          {
              "month": 12,
              "total_transactions": 16230,
              "year": 2019
          }
      ]
      ```
      * Response(Success) `group=day`:
      ```json
      [
          {
              "day": 7,
              "month": 12,
              "total_transactions": 100,
              "year": 2015
          },
          {
              "day": 7,
              "month": 12,
              "total_transactions": 100,
              "year": 2016
          },
          {
              "day": 7,
              "month": 2,
              "total_transactions": 100,
              "year": 2018
          }
      ]
      ```
      * Response(Success) `group=all_time`:
      ```json
        [
          {
              "total_transactions": 17030
          }
        ]
      ```
