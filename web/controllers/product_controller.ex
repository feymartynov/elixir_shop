defmodule ElixirShop.ProductController do
  use ElixirShop.Web, :controller

  alias ElixirShop.Product

  def index(conn, _params) do
    products = Repo.all(Product)
    render(conn, "index.html", products: products)
  end

  def show(conn, %{"id" => id}) do
    product = Repo.get!(Product, id)
    render(conn, "show.html", product: product)
  end
end
