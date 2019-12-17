defmodule DamEx.Files.FileRef do
  use DamEx.Schema
  import Ecto.Changeset
  alias DamEx.Files.Metadata

  schema "file_refs" do
    field :filename, :string
    field :mime_type, :string
    field :size, :integer
    field :uploaded_at, :utc_datetime_usec

    has_one :metadata, Metadata

    timestamps()
  end

  @doc false
  def changeset(file_ref, attrs) do
    file_ref
    |> cast(attrs, [:filename, :mime_type, :size])
    |> validate_required([:filename, :mime_type, :size])
  end
end
