defmodule ElixirShop.Transactions.RemoveFromCartTransactionTest do
  use ElixirShop.ModelCase

  alias ElixirShop.{Repo, Order, Order.Line}
  alias ElixirShop.Transactions.{AddToCart, RemoveFromCart}

  setup do
    {order, product} = {create(:order), create(:product)}
    {:ok, order, line, _log} = AddToCart.run(order, product, 2)
    {:ok, order: order, order_line: line}
  end

  test "it should remove the line", %{order: order, order_line: line} do
    {:ok, _order, _log} = RemoveFromCart.run(order, line)
    order = Repo.get!(Order, order.id) |> Repo.preload(:lines)
    assert order.lines == []
  end

  test "it should decrease total", %{order: order, order_line: line} do
    {:ok, order, _log} = RemoveFromCart.run(order, line)
    assert order.total == 0
  end

  test "it should log item adding", %{order: order, order_line: line} do
    {:ok, _order, log} = RemoveFromCart.run(order, line)

    assert log.event == "line_removed"
    assert log.user_id == order.customer_id
    assert log.humanized == "Removed \"Beer\" (2 pcs.) from cart"
    assert log.options.order_line_id == line.id
  end

  test "it should fail on alien line", %{order: order, order_line: _line} do
    result = RemoveFromCart.run(order, %Line{})
    assert result == {:error, "The line doesn't belong to the order"}
  end
end
