defmodule ElixirShop.OrderTest do
  use ElixirShop.ModelCase

  alias ElixirShop.Order
  alias ElixirShop.User

  defp create_order do
    user = build(:user) |> User.changeset(%{}) |> Repo.insert!
    %Order{customer_id: user.id} |> Order.changeset(%{}) |> Repo.insert!
  end

  test "it should have token" do
    order = create_order
    assert order.token
  end

  test "it should keep token on save" do
    order = create_order
    original_token = order.token
    order = Order.changeset(order, %{}) |> Repo.update!
    assert order.token == original_token
  end

  test "it should add a item to cart" do
    order = create_order
    product = create(:product)
    Order.add_item(order, product)
    line = Repo.preload(order, :lines).lines |> List.first

    assert line.product_id == product.id
    assert line.title == product.title
    assert line.items_number == 1
    assert line.item_price == product.price
    assert line.total_price == product.price
  end

  test "it should increase items number on adding the same product twice" do
    order = create_order
    product = create(:product)
    Order.add_item(order, product)
    Order.add_item(order, product)
    line = Repo.preload(order, :lines).lines |> List.first

    assert line.items_number == 2
    assert line.total_price == product.price * 2
  end

  test "it should update total on item adding" do
    order = create_order
    Order.add_item(order, create(:product, price: 729), 3)
    Order.add_item(order, create(:product, price: 824), 2)
    order = Repo.get(Order, order.id)

    assert order.total == 729 * 3 + 824 * 2
  end

  test "it should log item adding" do
    order = create_order
    product = create(:product)
    line = Order.add_item(order, product, 7)
    log = Repo.preload(order, :events).events |> List.last

    assert log.event == "item_added"
    assert log.user_id == order.customer_id
    assert log.options == %{
      "order_line_id" => line.id,
      "product_id" => product.id,
      "items_number" => 7}
  end
end
