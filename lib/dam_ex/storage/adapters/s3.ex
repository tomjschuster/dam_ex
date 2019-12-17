defmodule DamEx.Storage.Adapters.S3 do
  alias DamEx.Config
  @behaviour DamEx.Storage.Adapter

  defp bucket do
    Config.fetch!(DamEx.Storage.Adapters.S3, :bucket)
  end

  @impl true
  def url(key, method) do
    :s3
    |> ExAws.Config.new()
    |> ExAws.S3.presigned_url(method, bucket(), key)
  end

  @impl true
  def delete(key) do
    bucket()
    |> ExAws.S3.delete_object(key)
    |> ExAws.request()
    |> case do
      {:ok, _} -> :ok
      error -> error
    end
  end
end
