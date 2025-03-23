# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :lgb,
  ecto_repos: [Lgb.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configures the endpoint
config :lgb, LgbWeb.Endpoint,
  url: [host: "localhost"],
  check_origin: ["https://bii-bi.com", "https://lgb-old-cherry-6909.fly.dev"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: LgbWeb.ErrorHTML, json: LgbWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Lgb.PubSub,
  live_view: [signing_salt: "mfYSWkWX"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#

config :ueberauth, Ueberauth,
  providers: [
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ]

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  lgb: [
    args:
      ~w(js/app.ts --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.0",
  lgb: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Flop pagination configuration
config :flop, repo: Lgb.Repo

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
