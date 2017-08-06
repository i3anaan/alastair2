defmodule Alastair.Repo.Migrations.CreateShoppingItem do
  use Ecto.Migration

  def change do
    create table(:shopping_items) do
      add :comment, :string
      add :buying_quantity, :float
      add :price, :float
      add :buying_measurement_id, references(:measurements, on_delete: :nothing)
      add :mapped_ingredient_id, references(:ingredients, on_delete: :nothing)
      add :shop_id, references(:shops, on_delete: :nothing)

      timestamps()
    end
    create index(:shopping_items, [:buying_measurement_id])
    create index(:shopping_items, [:mapped_ingredient_id])
    create index(:shopping_items, [:shop_id])

  end
end
