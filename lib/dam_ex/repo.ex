defmodule DamEx.Repo do
  use Ecto.Repo,
    otp_app: :dam_ex,
    adapter: Ecto.Adapters.Postgres
end
