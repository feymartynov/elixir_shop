defmodule ElixirShop.Order.LineController do
  use ElixirShop.Web, :controller
  plug ElixirShop.Plugs.RequireAuth

  alias ElixirShop.Order
  alias ElixirShop.Product
  alias ElixirShop.Transactions.AddToCart
  alias ElixirShop.Router.Helpers

  def create(conn, %{"order_id" => token, "product_id" => product_id}) do
    {:ok, {:ok, order, _line, _log}} = Repo.transaction fn ->
      product = Repo.get!(Product, product_id)
      order = find_or_create_order(conn.assigns.current_user, token)
      AddToCart.run(order, product)
    end

    redirect conn, to: Helpers.order_path(conn, :show, order.token)
  end

  defp find_or_create_order(customer, token) do
    if token == "current" do
      order = Repo.one(from o in Order,
        where: (o.customer_id == ^customer.id and o.state == "shopping"),
        limit: 1)

      order ||
        %Order{customer_id: customer.id}
        |> Order.changeset(%{})
        |> Repo.insert!
    else
      Repo.get_by!(Order, customer_id: customer.id, token: token)
    end
  end
end
