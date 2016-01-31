defmodule ElixirShop.Repo.Migrations.CreateProduct do
  use Ecto.Migration

  def change do
    create table(:products) do
      add :title, :string
      add :description, :string
      add :price, :integer

      timestamps
    end

    create index(:products, [:updated_at])
  end
end
