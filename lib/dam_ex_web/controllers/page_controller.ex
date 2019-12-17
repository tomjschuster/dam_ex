defmodule DamExWeb.PageController do
  use DamExWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
