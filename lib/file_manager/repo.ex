defmodule FileManager.Repo do
  use Ecto.Repo,
    otp_app: :file_manager,
    adapter: Ecto.Adapters.Postgres
end
