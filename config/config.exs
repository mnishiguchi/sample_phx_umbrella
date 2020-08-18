# This file is responsible for configuring your umbrella
# and **all applications** and their dependencies with the
# help of Mix.Config.
#
# Note that all applications in your umbrella share the
# same configuration and dependencies, which is why they
# all use the same configuration file. If you want different
# configurations or dependencies per app, it is best to
# move said applications out of the umbrella.
use Mix.Config

# Configure Mix tasks and generators
config :sample_phx,
  ecto_repos: [SamplePhx.Repo]

config :sample_phx_web,
  ecto_repos: [SamplePhx.Repo],
  generators: [context_app: :sample_phx]

# Configures the endpoint
config :sample_phx_web, SamplePhxWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "5LVhmAdTvUGV38FAb6p9XI1b1E1u1OPdSKiVd0o8aLvweWeBmaeDAaFgmjKns/ps",
  render_errors: [view: SamplePhxWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: SamplePhx.PubSub,
  live_view: [signing_salt: "F7rBBrOw"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
