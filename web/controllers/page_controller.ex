defmodule ElixirShop.PageController do
  use ElixirShop.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
