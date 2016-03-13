defmodule ElixirShop.Transactions.UpdateCartItemsTest do
  use ElixirShop.ModelCase

  alias ElixirShop.Order
  alias ElixirShop.Transactions.{AddToCart, UpdateCartItems}

  setup do
    # 10 * 1 + 20 * 2 + 30 * 3 = 10 + 40 + 90 = 140
    {order, lines} =
      Enum.reduce(1..3, {create(:order), []}, fn(i, {order, lines}) ->
        product = create(:product, price: 10 * i)
        {:ok, order, line, _log} = AddToCart.run(order, product, i)
        {order, [line|lines]}
      end)

    # 10 * 2 + 20 * 8 + 30 * 3 = 20 + 160 + 90 = 270
    lines_params = [
      {Integer.to_string(Enum.at(lines, 1).id), %{"items_number" => "8"}},
      {Integer.to_string(Enum.at(lines, 2).id), %{"items_number" => "2"}}]

    order = Repo.preload(order, :lines)
    {:ok, order, logs} = UpdateCartItems.run(order, lines_params)

    order = Repo.get(Order, order.id) |> Repo.preload(:lines)
    {:ok, order: order, logs: logs}
  end

  test "it should change lines' items numbers", %{order: order} do
    items_numbers = for l <- order.lines, do: l.items_number
    assert items_numbers == [3, 8, 2]
  end

  test "it should change lines' totals", %{order: order} do
    total_prices = for l <- order.lines, do: l.total_price
    assert total_prices == [90, 160, 20]
  end

  test "it should update order total", %{order: order} do
    assert order.total == 270
  end

  test "it should log events", %{order: order, logs: logs} do
    assert length(logs) == 2

    for log <- logs do
      line = Enum.find(order.lines, &(&1.id == log.options.order_line_id))
      assert log.options.items_number == line.items_number
      assert log.event == "line_updated"
      assert log.user_id == order.customer_id
    end
  end

  test "it should fail for paid order", %{order: order} do
    order = Order.changeset(order, %{state: "paid"}) |> Repo.update!
    assert {:error, _} = UpdateCartItems.run(order, [])
  end
end
