defmodule ElixirShop.Transactions.RemoveFromCart do
  alias ElixirShop.{Repo, Order, Order.Line}

  def run(order, line) do
    cond do
      order.state != "shopping" ->
        {:error, "The order is not in shopping state"}
      line.order_id != order.id ->
        {:error, "The line doesn't belong to the order"}
      true ->
        Repo.delete!(line)
        order = decrease_total(order, line)
        log = log_event(order, line)
        {:ok, order, log}
    end
  end

  defp decrease_total(order, line) do
    total = order.total - line.total_price
    Order.changeset(order, %{total: total}) |> Repo.update!
  end

  defp log_event(order, line) do
    event = Ecto.build_assoc(order, :events,
      event: "line_removed",
      user_id: order.customer_id,
      humanized: "Removed #{Line.to_string(line)} from cart",
      options: %{order_line_id: line.id})

    Repo.insert!(event)
  end
end
