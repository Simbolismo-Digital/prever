defmodule Prever.Repo do
  use Ecto.Repo,
    otp_app: :prever,
    adapter: Ecto.Adapters.Postgres
end
