defmodule ElixirShop.Order do
  use ElixirShop.Web, :model

  alias ElixirShop.User
  alias ElixirShop.Order.Line
  alias ElixirShop.Order.Event

  schema "orders" do
    field :token, :string
    field :state, :string, default: "shopping"
    field :total, :integer, default: 0
    timestamps

    belongs_to :customer, User
    has_many :lines, Line
    has_many :events, Event
  end

  @required_fields ~w(state total customer_id)
  @optional_fields ~w()

  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> set_token
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
