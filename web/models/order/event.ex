defmodule ElixirShop.Order.Event do
  use ElixirShop.Web, :model

  schema "order_events" do
    field :event, :string
    field :options, :map
    timestamps updated_at: false

    belongs_to :order, ElixirShop.Order
    belongs_to :user, ElixirShop.User
  end

  @required_fields ~w(event order_id user_id)
  @optional_fields ~w(options)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
