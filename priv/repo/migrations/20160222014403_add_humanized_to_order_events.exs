defmodule ElixirShop.Repo.Migrations.AddHumanizedToOrderEvents do
  use Ecto.Migration

  def change do
    alter table(:order_events) do
      add :humanized, :string
    end
  end
end
