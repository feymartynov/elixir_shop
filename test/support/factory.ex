defmodule ElixirShop.Factory do
  use ExMachina.Ecto, repo: ElixirShop.Repo

  alias ElixirShop.User
  alias ElixirShop.Product
  alias ElixirShop.Order

  def factory(:user) do
    user = %User{
      name: "suhorot",
      email: "suhorot@example.com",
      password: "qwe123"}

    User.changeset(user)
    |> Ecto.Changeset.apply_changes
  end

  def factory(:product) do
    %Product{
      title: "Beer",
      description: "Unfiltered",
      price: 210}
  end

  def factory(:order) do
    %Order{customer: build(:user)}
    |> Order.changeset
    |> Ecto.Changeset.apply_changes
  end
end
