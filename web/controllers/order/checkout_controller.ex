defmodule ElixirShop.Order.CheckoutController do
  use ElixirShop.Web, :controller
  plug ElixirShop.Plugs.RequireAuth

  alias ElixirShop.Order

  def show(conn, %{"order_id" => token}) do
    render(conn, "show.html", order: find_order(conn, token))
  end

  def create(conn, %{"order_id" => token, "payment_method_nonce" => nonce}) do
    order = find_order(conn, token)

    case ElixirShop.Transactions.Checkout.run(order, nonce) do
      {:ok, order, _} -> render(conn, "success.html", order: order)
      {:error, _} -> render(conn, "error.html", order: order)
    end
  end

  defp find_order(conn, token) do
    Repo.get_by!(Order,
      customer_id: conn.assigns.current_user.id,
      token: token)
  end
end
