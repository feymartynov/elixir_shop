defmodule ElixirShop.OrderController do
  use ElixirShop.Web, :controller
  plug ElixirShop.Plugs.RequireAuth

  alias ElixirShop.{Order, Transactions.UpdateCartItems }
  alias ElixirShop.Router.Helpers

  def index(conn, _params) do
    orders = Repo.all from o in Order,
      where: o.customer_id == ^conn.assigns.current_user.id

    render(conn, "index.html", orders: orders)
  end

  def show(conn, %{"id" => token}) do
    order = find_order(conn, token)
    render(conn, "show.html", order: order)
  end

  def update(conn, %{"id" => token, "order" => %{ "lines" => lines }}) do
    {:ok, {:ok, order}} = Repo.transaction fn ->
      order = find_order(conn, token)
      UpdateCartItems.run(order, lines)
    end

    redirect conn, to: Helpers.order_path(conn, :show, order.token)
  end

  defp find_order(conn, token) do
    Repo.one(from o in Order,
      where: (
        o.customer_id == ^conn.assigns.current_user.id and
        o.token == ^token),
      preload: [:lines, :events])
  end
end
