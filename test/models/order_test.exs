defmodule ElixirShop.OrderTest do
  use ElixirShop.ModelCase, async: true

  alias ElixirShop.Order

  test "it should have token" do
    order = Order.changeset(build(:order), %{}) |> Ecto.Changeset.apply_changes
    assert order.token
  end

  test "it should keep token on save" do
    order = build(:order, token: "zxcvb")
    original_token = order.token
    order = Order.changeset(order, %{}) |> Ecto.Changeset.apply_changes
    assert order.token == original_token
  end
end
