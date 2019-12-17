defmodule DamEx.Config do
  def fetch!(opt, key) do
    :dam_ex
    |> Application.fetch_env!(opt)
    |> Keyword.fetch!(key)
  end
end
