require IEx

defmodule ElixirShop.Transactions.UpdateCartItems do
  alias ElixirShop.{Repo, Order, Order.Line}

  def run(order, lines_params) do
    if order.state == "shopping" do
      lines = update_lines(order, lines_params)
      logs = for line <- lines, do: log_event(order, line)
      order = recalculate_total(order, lines)
      {:ok, order, logs}
    else
      {:error, "The order is not in shopping state"}
    end
  end

  defp update_lines(order, lines_params) do
    for {line_id, %{"items_number" => items_number}} <- lines_params do
      {line_id, _} = Integer.parse(line_id)
      line = Enum.find(order.lines, fn(l) -> l.id == line_id end)
      {items_number, _} = Integer.parse(items_number)
      update_line(line, items_number)
    end
  end

  defp update_line(line, items_number) do
    Repo.update! Line.changeset(line, %{
      items_number: items_number,
      total_price: items_number * line.item_price})
  end

  defp recalculate_total(order, changed_lines) do
    totals = Enum.reduce(
      order.lines ++ changed_lines,
      %{},
      fn(l, acc) -> Map.put(acc, l.id, l.total_price) end)

    total = Enum.reduce(totals, 0, fn({_, t}, acc) -> acc + t end)
    Repo.update! Order.changeset(order, %{total: total})
  end

  defp log_event(order, line) do
    event = Ecto.build_assoc(order, :events,
      event: "line_updated",
      user_id: order.customer_id,
      humanized: "Updated #{Line.to_string(line)} items number to #{line.items_number}",
      options: %{order_line_id: line.id, items_number: line.items_number})

    Repo.insert!(event)
  end
end
