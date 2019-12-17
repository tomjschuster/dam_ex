defmodule DamEx.Files.Metadata do
  use DamEx.Schema
  import Ecto.Changeset

  schema "metadata" do
    field :title, :string
    field :file_ref_id, Ecto.UUID

    timestamps()
  end

  @doc false
  def changeset(metadata, attrs) do
    metadata
    |> cast(attrs, [:title])
  end
end
