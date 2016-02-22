defmodule ElixirShop.Transactions.AddToCart do
  alias ElixirShop.{Repo, Order, Order.Line}

  def run(order, product, items_number \\ 1) do
    {line, log} = add_item(order, product, items_number)
    order = increase_total(order, line)
    {:ok, order, line, log}
  end

  defp add_item(order, product, items_number) do
    existing_line = Repo.get_by(Line,
      order_id: order.id,
      product_id: product.id)

    if existing_line do
      line = increase_items_number(existing_line, items_number)
      log = log_increased_line(order, line, items_number)
      {line, log}
    else
      line = create_new_line(order, product, items_number)
      log = log_created_line(order, line, product, items_number)
      {line, log}
    end
  end

  defp increase_items_number(line, increment) do
    increased_items_number = line.items_number + increment
    total_price = increased_items_number * line.item_price

    Repo.update! Line.changeset(line, %{
      items_number: increased_items_number,
      total_price: total_price})
  end

  defp log_increased_line(order, line, items_number) do
    Repo.insert! Ecto.build_assoc(order, :events,
      event: "line_items_number_increased",
      user_id: order.customer_id,
      humanized: "Increased \"#{line.title}\" number by #{items_number}",
      options: %{
        order_line_id: line.id,
        items_number: items_number})
  end

  defp create_new_line(order, product, items_number) do
    line = Ecto.build_assoc(order, :lines,
      product_id: product.id,
      title: product.title,
      items_number: items_number,
      item_price: product.price,
      total_price: product.price * items_number)

    Line.changeset(line, %{}) |> Repo.insert!
  end

  defp log_created_line(order, line, product, items_number) do
    Repo.insert! Ecto.build_assoc(order, :events,
      event: "line_added",
      user_id: order.customer_id,
      humanized: "Added #{Line.to_string(line)} to cart",
      options: %{
        order_line_id: line.id,
        product_id: product.id,
        items_number: items_number})
  end

  defp increase_total(order, line) do
    total = order.total + line.total_price
    Order.changeset(order, %{total: total}) |> Repo.update!
  end
end
