defmodule ElixirShop.Product do
  use ElixirShop.Web, :model

  schema "products" do
    field :title, :string
    field :description, :string
    field :price, :integer
    timestamps
  end

  @required_fields ~w(title price)
  @optional_fields ~w(description)

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
