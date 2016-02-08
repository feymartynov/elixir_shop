defmodule ElixirShop.Order do
  use ElixirShop.Web, :model

  alias ElixirShop.Repo
  alias ElixirShop.Order.Line

  schema "orders" do
    field :token, :string
    field :state, :string, default: "shopping"
    field :total, :integer, default: 0
    timestamps

    belongs_to :customer, ElixirShop.User
    has_many :lines, ElixirShop.Order.Line
    has_many :events, ElixirShop.Order.Event
  end

  @required_fields ~w(state total customer_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> set_token
  end

  def add_item(order, product, items_number \\ 1) do
    line = Repo.get_by(Line, order_id: order.id, product_id: product.id)

    line = if line do
      increment_line(line, items_number)
    else
      add_line(order, product, items_number)
    end

    order |> set_total |> Repo.update!
    log_item_added(order, line, product, items_number)
    line
  end

  defp add_line(order, product, items_number) do
    Repo.insert!(%Line{
      order_id: order.id,
      product_id: product.id,
      title: product.title,
      items_number: items_number,
      item_price: product.price,
      total_price: product.price * items_number})
  end

  defp increment_line(line, number) do
    items_number = line.items_number + number
    total_price = items_number * line.item_price

    line
    |> Line.changeset(%{items_number: items_number, total_price: total_price})
    |> Repo.update!
  end

  defp log_item_added(order, line, product, items_number) do
    log = Ecto.build_assoc(order, :events, %{
      event: "item_added",
      user_id: order.customer_id,
      options: %{
        order_line_id: line.id,
        product_id: product.id,
        items_number: items_number}})

    Repo.insert!(log)
  end

  defp set_total(changeset) do
    lines = Repo.preload(changeset, :lines).lines
    total = Enum.reduce(lines, 0, fn(l, acc) -> acc + l.total_price end)
    change(changeset, %{total: total})
  end

  defp set_token(changeset) do
    case Ecto.Changeset.get_field(changeset, :token) do
      nil ->
        token =
          :os.timestamp
          |> Tuple.to_list
          |> Enum.join
          |> Comeonin.Pbkdf2.Base64.encode

        change(changeset, %{token: token})
      _ -> changeset
    end
  end
end
