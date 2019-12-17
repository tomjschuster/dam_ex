defmodule DamEx.Repo.Migrations.CreateMetadata do
  use Ecto.Migration

  def change do
    create table(:metadata) do
      add :title, :string, null: true
      add :file_ref_id, references(:file_refs, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:metadata, [:file_ref_id])
  end
end
