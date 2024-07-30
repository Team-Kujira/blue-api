# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :blue_api,
  ecto_repos: [BlueApi.Repo]

# Configures the endpoint
config :blue_api, BlueApiWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [view: BlueApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: BlueApi.PubSub,
  live_view: [signing_salt: "qoLhVOOB"],
  protocol_options: [idle_timeout: 60_000]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :cors_plug,
  origin: [~r/https:\/\/([a-z]+\.)?kujira\.network$/, "http://localhost:1234"]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
