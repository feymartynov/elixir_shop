defmodule ElixirShop.OrderController do
  use ElixirShop.Web, :controller
  plug ElixirShop.Plugs.RequireAuth

  alias ElixirShop.Order

  def index(conn, _params) do
    orders = Repo.all from o in Orders,
      where: o.customer_id == ^conn.assigns.current_user.id

    render(conn, "index.html", orders: orders)
  end

  def show(conn, %{"id" => token}) do
    order = Repo.get_by! Order,
      customer_id: conn.assigns.current_user.id,
      token: token,
      preload: [:lines]

    render(conn, "show.html", order: order)
  end
end
