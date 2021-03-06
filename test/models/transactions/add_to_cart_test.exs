defmodule ElixirShop.Transactions.AddToCartTest do
  use ElixirShop.ModelCase

  alias ElixirShop.Transactions.AddToCart

  test "it should add a new line to the order" do
    {order, product} = {create(:order), create(:product)}
    {:ok, _order, line, _log} = AddToCart.run(order, product)

    assert line.product_id == product.id
    assert line.title == product.title
    assert line.items_number == 1
    assert line.item_price == product.price
    assert line.total_price == product.price
  end

  test "it should increase items number on adding the same product twice" do
    {order, product} = {create(:order), create(:product)}
    {:ok, order, _line, _log} = AddToCart.run(order, product)
    {:ok, _order, line, _log} = AddToCart.run(order, product)

    assert line.items_number == 2
    assert line.total_price == product.price * 2
  end

  test "it should increase total on item adding" do
    order = create(:order)
    {:ok, order, _, _} = AddToCart.run(order, create(:product, price: 729), 3)
    {:ok, order, _, _} = AddToCart.run(order, create(:product, price: 824), 2)

    assert order.total == 729 * 3 + 824 * 2
  end

  test "it should log line adding" do
    {order, product} = {create(:order), create(:product, title: "Stuff")}
    {:ok, _order, line, log} = AddToCart.run(order, product, 7)

    assert log.event == "line_added"
    assert log.user_id == order.customer_id
    assert log.humanized == "Added \"Stuff\" (7 pcs.) to cart"
    assert log.options == %{
      order_line_id: line.id,
      product_id: product.id,
      items_number: 7}
  end

  test "it should log line items count increment" do
    {order, product} = {create(:order), create(:product)}
    {:ok, order, _line, _log} = AddToCart.run(order, product)
    {:ok, _order, line, log} = AddToCart.run(order, product, 4)

    assert log.event == "line_items_number_increased"
    assert log.user_id == order.customer_id
    assert log.humanized == "Increased \"Beer\" number by 4"
    assert log.options == %{order_line_id: line.id, items_number: 4}
  end

  test "it should fail for paid order" do
    {order, product} = {create(:order, state: "paid"), create(:product)}
    assert {:error, _} = AddToCart.run(order, product)
  end
end
