defmodule ElixirShop.Order.CheckoutController do
  use ElixirShop.Web, :controller
  plug ElixirShop.Plugs.RequireAuth

  alias ElixirShop.{Order, Transactions.Checkout}

  def show(conn, %{"order_id" => token}) do
    order = find_order(conn, token) |> Repo.preload(:customer)
    render(conn, "show.html", order: order)
  end

  def create(conn, %{
    "order_id" => token,
    "payment_method_nonce" => nonce,
    "order" => checkout_params}) do

    order = find_order(conn, token)

    case Checkout.run(order, nonce, checkout_params) do
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
