defmodule FileManager.Transfer.Adapters.S3 do
  use FileManager.Transfer.Adapter
  alias FileManager.Config

  def bucket, do: Config.fetch!(__MODULE__, :bucket)
  def base_url, do: "https://#{bucket()}.s3.amazonaws.com"

  @impl true
  def get_signed_url(path, method) do
    ExAws.Config.new(:s3)
    |> ExAws.S3.presigned_url(method, bucket(), path, [])
  end
end
