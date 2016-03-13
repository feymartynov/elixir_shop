defmodule ElixirShop.Transactions.Checkout do
  alias ElixirShop.{Repo, Order}

  def run(order, nonce, checkout_params) do
    if order.state == "shopping" do
      order = Order.checkout_changeset(order, checkout_params) |> Repo.update!
      payment(order, nonce)
    else
      {:error, "The order is not in shopping state"}
    end
  end

  defp payment(order, nonce) do
    case call_braintree(order, nonce) do
      {:ok, transaction} ->
        log = log_success(order, transaction)
        order = Order.changeset(order, %{state: "paid"}) |> Repo.update!
        {:ok, order, log}
      {:error, error} ->
        log = log_failure(order, error)
        {:error, log}
    end
  end

  defp call_braintree(order, nonce) do
    amount = order.total / 100.0
      |> Float.round(2)
      |> Float.to_string(decimals: 2)

    Braintree.Transaction.sale(%{
      amount: amount,
      payment_method_nonce: nonce,
      options: %{submit_for_settlement: true}})
  end

  defp log_success(order, transaction) do
    event = Ecto.build_assoc(order, :events,
      event: "payment_succeeded",
      user_id: order.customer_id,
      humanized: "Payment succeeded",
      options: Map.from_struct(transaction))

    Repo.insert!(event)
  end

  defp log_failure(order, error) do
    event = Ecto.build_assoc(order, :events,
      event: "payment_failed",
      user_id: order.customer_id,
      humanized: "Payment failed",
      options: error.errors)

    Repo.insert!(event)
  end
end
