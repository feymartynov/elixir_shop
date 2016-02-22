defmodule ElixirShop.Transactions.AddToCart do
  alias ElixirShop.Repo
  alias ElixirShop.Order
  alias ElixirShop.Order.Line

  def run(order, product, items_number \\ 1) do
    line = add_item(order, product, items_number)
    order = increase_total(order, line)
    log = log_event(order, line, product, items_number)
    {:ok, order, line, log}
  end

  defp add_item(order, product, items_number) do
    existing_line = Repo.get_by(Order.Line,
      order_id: order.id,
      product_id: product.id)

    line_changeset = if existing_line do
      increase_items_number(existing_line, items_number)
    else
      build_new_line(order, product, items_number) |> Line.changeset(%{})
    end

    Repo.insert_or_update!(line_changeset)
  end

  defp increase_items_number(line, increment) do
    increased_items_number = line.items_number + increment
    total_price = increased_items_number * line.item_price

    Line.changeset(line, %{
      items_number: increased_items_number,
      total_price: total_price})
  end

  defp build_new_line(order, product, items_number) do
    Ecto.build_assoc(order, :lines,
      product_id: product.id,
      title: product.title,
      items_number: items_number,
      item_price: product.price,
      total_price: product.price * items_number)
  end

  defp increase_total(order, line) do
    total = order.total + line.total_price
    Order.changeset(order, %{total: total}) |> Repo.update!
  end

  defp log_event(order, line, product, items_number) do
    pcs = if items_number > 1, do: " (#{items_number} pcs.)", else: ""
    humanized = "Added \"#{product.title}\"#{pcs} to cart"

    event = Ecto.build_assoc(order, :events,
      event: "item_added",
      user_id: order.customer_id,
      humanized: humanized,
      options: %{
        order_line_id: line.id,
        product_id: product.id,
        items_number: items_number})

    Repo.insert!(event)
  end
end
