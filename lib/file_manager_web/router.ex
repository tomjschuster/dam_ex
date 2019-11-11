defmodule FileManagerWeb.Router do
  use FileManagerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", FileManagerWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", FileManagerWeb.Api do
    pipe_through :api

    get "/signed-upload-url", FileManagerController, :signed_upload_url
  end
end
