defmodule ElixirShop.Repo.Migrations.AddCheckoutFields do
  use Ecto.Migration

  def change do
    alter table :orders do
      add :customer_name, :string, default: ""
      add :phone, :string, default: ""
      add :email, :string, default: ""
      add :address, :string, default: ""
    end

    alter table :users do
      add :phone, :string, default: ""
      add :address, :string, default: ""
    end
  end
end
