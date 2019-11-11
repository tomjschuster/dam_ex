defmodule FileManager.Transfer.Adapter do
  defmacro __using__(_) do
    quote do
      @behaviour unquote(__MODULE__)
    end
  end

  @type t :: module

  @callback get_signed_url(path :: String.t(), method :: String.t()) ::
              {:ok, String.t()} | {:error, String.t()}
end
