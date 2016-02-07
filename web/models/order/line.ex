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

  @required_fields ~w(title order product items_number item_price total_price)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
