# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :dam_ex,
  ecto_repos: [DamEx.Repo]

config :dam_ex, DamEx.Repo,
  migration_primary_key: [type: :binary_id],
  migration_timestamps: [type: :utc_datetime_usec]

# Configures the endpoint
config :dam_ex, DamExWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "BBrr2jroYPdkaIF+wxB6nRL/eQb9bFrQU0gUsnajbJqoLIXwHakCLWgo0tKabjqM",
  render_errors: [view: DamExWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: DamEx.PubSub, adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
