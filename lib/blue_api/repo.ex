defmodule BlueApi.Repo do
  use Ecto.Repo,
    otp_app: :blue_api,
    adapter: Ecto.Adapters.Postgres
end
