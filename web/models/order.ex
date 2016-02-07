defmodule ElixirShop.Order do
  use ElixirShop.Web, :model

  schema "orders" do
    field :token, :string
    field :state, :string, default: "shopping"
    field :total, :integer, default: 0
    timestamps

    belongs_to :customer, ElixirShop.User
    has_many :lines, ElixirShop.Order.Line
    has_many :events, ElixirShop.Order.Event
  end

  @required_fields ~w(token state total customer)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
