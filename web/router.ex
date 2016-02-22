defmodule ElixirShop.Router do
  use ElixirShop.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug ElixirShop.Plugs.CurrentUser
  end

  scope "/auth", ElixirShop do
    pipe_through :browser

    resources "/register", UserController, only: [:new, :create]
    resources "/login", AuthController, only: [:new, :create]
    delete "/logout", AuthController, :delete
  end

  scope "/", ElixirShop do
    pipe_through :browser

    get "/", ProductController, :index
    resources "products", ProductController, only: [:show]

    resources "orders", OrderController, only: [:index, :show] do
      resources "lines", Order.LineController, only: [:create, :delete]
    end
  end
end
