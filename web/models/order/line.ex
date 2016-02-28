defmodule ElixirShop.Order.Line do
  use ElixirShop.Web, :model

  schema "order_lines" do
    field :title, :string
    field :items_number, :integer, default: 1
    field :item_price, :integer
    field :total_price, :integer
    timestamps

    belongs_to :order, ElixirShop.Order
    belongs_to :product, ElixirShop.Product
  end

  @required_fields ~w(title order_id product_id items_number item_price total_price)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> validate_number(:items_number, greater_than_or_equal_to: 1, less_than: 100)
    |> validate_number(:item_price, greater_than: 0)
    |> validate_number(:total_price, greater_than: 0)
  end

  def to_string(line) do
    pcs = if line.items_number > 1, do: " (#{line.items_number} pcs.)", else: ""
    "\"#{line.title}\"#{pcs}"
  end
end
