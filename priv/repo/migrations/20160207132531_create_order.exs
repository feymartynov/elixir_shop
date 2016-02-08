defmodule ElixirShop.Repo.Migrations.CreateOrder do
  use Ecto.Migration

  def change do
    create table(:orders) do
      add :token, :string, null: false
      add :customer_id, references(:users), null: false
      add :state, :string, null: false, default: "shopping"
      add :total, :integer, null: false, default: 0
      timestamps
    end

    create index(:orders, [:token], unique: true)
    create index(:orders, [:customer_id])
    create index(:orders, [:inserted_at])

    create table(:order_lines) do
      add :order_id, references(:orders), null: false
      add :product_id, references(:products), null: false
      add :title, :string, null: false
      add :items_number, :integer, null: false, default: 1
      add :item_price, :integer, null: false
      add :total_price, :integer, null: false
      timestamps
    end

    create index(:order_lines, [:order_id])

    create table(:order_events) do
      add :order_id, references(:orders), null: false
      add :event, :string, null: false
      add :options, :map
      add :user_id, references(:users)
      add :inserted_at, :datetime, null: false
    end

    create index(:order_events, [:order_id])
    create index(:order_events, [:user_id])
    create index(:order_events, [:inserted_at])
  end
end
