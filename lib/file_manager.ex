defmodule FileManager do
  defdelegate get_signed_url(path, method), to: FileManager.Transfer
end
