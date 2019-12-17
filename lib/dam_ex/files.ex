defmodule DamEx.Files do
  require Ecto.Query
  alias DamEx.Files.Metadata
  alias DamEx.Files.FileRef
  alias DamEx.Repo
  alias DamEx.Storage
  alias Ecto.Changeset
  alias Ecto.Multi
  alias Ecto.Query

  def create_ref(params) do
    %FileRef{}
    |> FileRef.changeset(params)
    |> Changeset.put_assoc(:metadata, %Metadata{})
    |> Repo.insert()
  end

  def get_ref!(id) do
    FileRef
    |> Query.preload(:metadata)
    |> Repo.get!(id)
  end

  def list_refs do
    FileRef
    |> Query.preload(:metadata)
    |> Repo.all()
  end

  def set_ref_uploaded(file_ref) do
    file_ref
    |> Changeset.change()
    |> Changeset.put_change(:uploaded_at, DateTime.utc_now())
    |> Repo.update()
  end

  def update_metadata(metadata, params) do
    metadata
    |> Metadata.changeset(params)
    |> Repo.update()
  end

  def delete_ref(file_ref) do
    Multi.new()
    |> Multi.delete(:delete_metadata, file_ref.metadata)
    |> Multi.delete(:delete_file_ref, file_ref)
    |> Multi.run(:delete_file_object, fn _, _ ->
      with :ok <- Storage.delete(file_ref.id), do: {:ok, nil}
    end)
    |> Repo.transaction()
    |> case do
      {:ok, _} -> :ok
      {:error, _, _, _} -> :error
    end
  end
end
