defmodule FileManager.Transfer do
  alias FileManager.Config

  defp adapter do
    Config.fetch!(FileManager.Transfer, :adapter)
  end

  def get_signed_url(path, method), do: adapter().get_signed_url(path, method)
end
