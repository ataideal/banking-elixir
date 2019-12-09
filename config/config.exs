# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :banking,
  ecto_repos: [Banking.Repo]

# Configures the endpoint
config :banking, BankingWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "q731odYvPfWlXKmjovcNizZyQT0AEnheNMIU24j/Ik7DRtj/zVBjnn/aYjkOlpup",
  render_errors: [view: BankingWeb.ErrorView, accepts: ~w(json)],
  pubsub: [name: Banking.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Get env
config :banking, env: Mix.env

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
