defmodule ElixirAssesment.Repo do
  use Ecto.Repo,
    otp_app: :elixir_assesment,
    adapter: Ecto.Adapters.Postgres
end
