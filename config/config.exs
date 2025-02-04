# config/config.exs
import Config

config :scrabble,
  ecto_repos: [Scrabble.Repo]

# Configures the endpoint
config :scrabble, ScrabbleWeb.Endpoint,
  url: [host: "localhost"],
  render_errors: [
    formats: [html: ScrabbleWeb.ErrorHTML, json: ScrabbleWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Scrabble.PubSub,
  live_view: [signing_salt: "YOUR_SIGNING_SALT"]

# Configure esbuild
config :esbuild,
  version: "0.17.11",
  scrabble: [
    args: ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind
config :tailwind,
  version: "3.3.2",
  scrabble: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config
import_config "#{config_env()}.exs"
