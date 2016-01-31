defmodule ElixirShop.ProductView do
  use ElixirShop.Web, :view

  def format_price(price) do
    price = price / 100.0 |> Float.round(2) |> Float.to_string(decimals: 2)
    "$#{price}"
  end
end
