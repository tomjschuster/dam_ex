defmodule DamExWeb.Router do
  use DamExWeb, :router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", DamExWeb do
    pipe_through(:browser)

    get("/", PageController, :index)
  end

  scope "/api", DamExWeb.Api do
    pipe_through(:api)

    post("/upload/start", FileController, :start_upload)
    post("/upload/complete", FileController, :complete_upload)
    get("/files", FileController, :index_files)
    get("/files/:id", FileController, :get_file)
    delete("/files/:id", FileController, :delete_file)
    patch("/files/:id/metadata", FileController, :update_metadata)
  end
end
