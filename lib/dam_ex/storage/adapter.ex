defmodule DamEx.Storage.Adapter do
  @callback url(key :: String.t(), method :: :get | :put) :: {:ok, String.t()} | {:error, term()}
  @callback delete(id :: String.t()) :: :ok | {:error, term()}
end
