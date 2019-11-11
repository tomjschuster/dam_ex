defmodule FileManager.Config do
  def fetch!(module, key) do
    :file_manager
    |> Application.fetch_env!(module)
    |> Keyword.fetch!(key)
  end
end
