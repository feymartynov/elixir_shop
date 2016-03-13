defmodule ElixirShop.Transactions.CheckoutTest do
  use ElixirShop.ModelCase
  import Mock

  alias ElixirShop.Transactions.Checkout
  alias Braintree.{Transaction, ErrorResponse}

  test "it should call the payment gate" do
    txn_params = %{
      amount: "123.45",
      payment_method_nonce: "qwerty",
      options: %{submit_for_settlement: true}}

    with_mock Transaction, [sale: fn(^txn_params) -> {:ok, %Transaction{}} end] do
      assert {:ok, _, _} = Checkout.run(create(:order, total: 12345), "qwerty")
    end
  end

  test "it should set the order paid" do
    with_mock Transaction, [sale: fn(_) -> {:ok, %Transaction{}} end] do
      {:ok, order, _} = Checkout.run(create(:order), "nevermind")
      assert order.state == "paid"
    end
  end

  test "it should log success" do
    order = create(:order)
    result = %Transaction{status: "test"}

    with_mock Transaction, [sale: fn(_) -> {:ok, result} end] do
      {:ok, _, log} = Checkout.run(order, "nevermind")

      assert log.event == "payment_succeeded"
      assert log.user_id == order.customer_id
      assert log.humanized == "Payment succeeded"
      assert log.options[:status] == "test"
    end
  end

  test "it should log failure" do
    order = create(:order)
    error = %ErrorResponse{errors: %{test: "noooo"}}

    with_mock Transaction, [sale: fn(_) -> {:error, error} end] do
      {:error, log} = Checkout.run(order, "nevermind")

      assert log.event == "payment_failed"
      assert log.user_id == order.customer_id
      assert log.humanized == "Payment failed"
      assert log.options == %{test: "noooo"}
    end
  end

  test "it should fail for paid order" do
    order = create(:order, state: "paid")
    assert {:error, _} = Checkout.run(order, "nevermind")
  end
end
