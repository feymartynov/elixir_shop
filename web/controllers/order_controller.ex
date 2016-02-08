defmodule ElixirShop.OrderController do
  use ElixirShop.Web, :controller
  plug ElixirShop.Plugs.RequireAuth

  alias ElixirShop.Order

  def index(conn, _params) do
    orders = Repo.all from o in Orders,
      where: o.customer_id == ^conn.current_user.id

    render(conn, "index.html", orders: orders)
  end

  def show(conn, params) do
    render(conn, "show.html", order: find_order(conn, params))
  end

  def add_item(conn, %{"product_id" => product_id} = params) do
    Repo.transaction fn ->
      order = find_order(conn, params)
      product = Repo.get!(Product, product_id)
      Order.add_item(order, product)
    end
  end

  defp find_order(conn, params) do
    Repo.get_by! Order,
      customer_id: conn.current_user.id,
      token: params["id"],
      preload: [lines: [:product]]
  end
end
