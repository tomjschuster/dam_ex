defmodule DamEx.Repo.Migrations.CreateFileRefs do
  use Ecto.Migration

  def change do
    create table(:file_refs) do
      add :filename, :string, null: false
      add :mime_type, :string, null: false
      add :size, :integer, null: false
      add :uploaded_at, :utc_datetime_usec, null: true

      timestamps()
    end
  end
end
