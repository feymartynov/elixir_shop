defmodule ElixirShop.Order.CheckoutView do
  use ElixirShop.Web, :view
  import ElixirShop.PriceHelpers

  def payment_token do
    {:ok, token} = Braintree.ClientToken.generate
    token
  end
end
