use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :banking, BankingWeb.Endpoint,
  http: [port: 4002],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :banking, Banking.Repo,
  username: "d0zero",
  password: "",
  database: "banking_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox

config :banking, Banking.Guardian,
  issuer: "banking",
  secret_key: "LQwt8/s6glDSHatBYxI+BzNX/9CYtllOdQ2CLxVmK2Bne1vvRye8gUwQuMJWwXO/"
