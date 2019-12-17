defmodule DamEx.Storage do
  alias DamEx.Config

  defp adapter, do: Config.fetch!(DamEx.Storage, :adapter)

  def url(key, method), do: adapter().url(key, method)
  def delete(id), do: adapter().delete(id)
end
