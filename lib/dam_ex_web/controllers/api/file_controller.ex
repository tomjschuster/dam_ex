defmodule DamExWeb.Api.FileController do
  use DamExWeb, :controller

  alias DamEx.Files
  alias DamEx.Storage

  def start_upload(conn, params) do
    with {:ok, file_ref} <- Files.create_ref(params),
         {:ok, upload_url} <- Storage.url(file_ref.id, :put) do
      json(conn, %{
        fileRef: %{
          id: file_ref.id,
          mimeType: file_ref.mime_type,
          filename: file_ref.filename,
          fileSize: file_ref.size
        },
        uploadUrl: upload_url
      })
    end
  end

  def complete_upload(conn, %{"id" => id}) do
    id
    |> Files.get_ref!()
    |> Files.set_ref_uploaded()
    |> case do
      {:ok, _} ->
        conn
        |> send_resp(:no_content, "")
    end
  end

  def index_files(conn, _params) do
    file_refs = Files.list_refs()

    json(
      conn,
      Enum.map(
        file_refs,
        &%{
          id: &1.id,
          mimeType: &1.mime_type,
          filename: &1.filename,
          fileSize: &1.size,
          metadata: %{
            fileRefId: &1.id,
            title: &1.metadata.title
          }
        }
      )
    )
  end

  def get_file(conn, %{"id" => id}) do
    case Storage.url(id, :get) do
      {:ok, url} ->
        redirect(conn, external: url)
    end
  end

  def update_metadata(conn, %{"id" => id, "metadata" => params}) do
    file_ref = Files.get_ref!(id)

    file_ref
    |> Map.fetch!(:metadata)
    |> Files.update_metadata(params)
    |> case do
      {:ok, metadata} ->
        json(conn, %{
          fileRefId: metadata.file_ref_id,
          title: metadata.title
        })
    end
  end

  def delete_file(conn, %{"id" => id}) do
    id
    |> Files.get_ref!()
    |> Files.delete_ref()
    |> case do
      :ok ->
        conn
        |> send_resp(:no_content, "")
    end
  end
end
