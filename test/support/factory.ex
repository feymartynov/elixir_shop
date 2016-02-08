defmodule ElixirShop.Factory do
  use ExMachina.Ecto, repo: ElixirShop.Repo

  alias ElixirShop.User
  alias ElixirShop.Product

  def factory(:user) do
    %User{
      name: "suhorot",
      email: "suhorot@example.com",
      password: "qwe123"}
  end

  def factory(:product) do
    %Product{
      title: "Beer",
      description: "Unfiltered",
      price: 210}
  end
end
