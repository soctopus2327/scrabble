defmodule Scrabble.Repo do
  use Ecto.Repo,
    otp_app: :scrabble,
    adapter: Ecto.Adapters.Postgres
end
