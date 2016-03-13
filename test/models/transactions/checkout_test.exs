defmodule ElixirShop.Transactions.CheckoutTest do
  use ElixirShop.ModelCase
  import Mock

  alias ElixirShop.Transactions.Checkout
  alias Braintree.{Transaction, ErrorResponse}

  @checkout_params %{
    customer_name: "user",
    phone: "12345",
    email: "user@example.com",
    address: "dunno"}

  test "it should update the order" do
    with_mock Transaction, [sale: fn(_) -> {:ok, %Transaction{}} end] do
      order = create(:order)
      {:ok, order, _} = Checkout.run(order, "nevermind", @checkout_params)
      assert order.customer_name == "user"
      assert order.phone == "12345"
      assert order.email == "user@example.com"
      assert order.address == "dunno"
    end
  end

  test "it should call the payment gate" do
    txn_params = %{
      amount: "123.45",
      payment_method_nonce: "qwerty",
      options: %{submit_for_settlement: true}}

    sale = fn(^txn_params) -> {:ok, %Transaction{}} end

    with_mock Transaction, [sale: sale] do
      order = create(:order, total: 12345)
      assert {:ok, _, _} = Checkout.run(order, "qwerty", @checkout_params)
    end
  end

  test "it should set the order paid" do
    with_mock Transaction, [sale: fn(_) -> {:ok, %Transaction{}} end] do
      order = create(:order)
      {:ok, order, _} = Checkout.run(order, "nevermind", @checkout_params)
      assert order.state == "paid"
    end
  end

  test "it should log success" do
    order = create(:order)
    result = %Transaction{status: "test"}

    with_mock Transaction, [sale: fn(_) -> {:ok, result} end] do
      {:ok, _, log} = Checkout.run(order, "nevermind", @checkout_params)

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
      {:error, log} = Checkout.run(order, "nevermind", @checkout_params)

      assert log.event == "payment_failed"
      assert log.user_id == order.customer_id
      assert log.humanized == "Payment failed"
      assert log.options == %{test: "noooo"}
    end
  end

  test "it should fail for paid order" do
    order = create(:order, state: "paid")
    assert {:error, _} = Checkout.run(order, "nevermind", @checkout_params)
  end
end
