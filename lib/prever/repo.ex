defmodule Prever.Repo do
  use Ecto.Repo,
    otp_app: :prever,
    adapter: Ecto.Adapters.Postgres

  def init(_type, config) do
    {:ok, Keyword.put(config, :types, Prever.PostgresTypes)}
  end
end
