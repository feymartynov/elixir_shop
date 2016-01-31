defmodule ElixirShop.Router do
  use ElixirShop.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ElixirShop.Plugs.Authentication
  end

  scope "/auth", ElixirShop do
    pipe_through :browser

    get "/register", UserController, :new
    post "/register", UserController, :create

    get "/login", AuthController, :new
    post "/login", AuthController, :create
    delete "/logout", AuthController, :destroy
  end

  scope "/", ElixirShop do
    pipe_through :browser

    get "/", PageController, :index
  end
end
