defmodule FileManagerWeb.Api.FileManagerController do
  use FileManagerWeb, :controller

  def signed_upload_url(conn, %{"path" => path}) do
    case FileManager.get_signed_url(path, :put) do
      {:ok, url} -> json(conn, %{url: url})
      {:error, error} -> conn |> put_status(:server_error) |> json(%{error: error})
    end
  end
end
