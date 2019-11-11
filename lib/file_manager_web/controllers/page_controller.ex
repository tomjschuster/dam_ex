defmodule FileManagerWeb.PageController do
  use FileManagerWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
