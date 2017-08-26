defmodule Alastair.Repo.Migrations.CreateShoppingListNote do
  use Ecto.Migration

  def change do
    create table(:shopping_list_notes) do
      add :event_id, :string
      add :ingredient_id, references(:ingredients, on_delete: :nothing)
      add :ticked, :boolean
      add :bought, :float
      add :shopping_item_id, references(:shopping_items, on_delete: :nothing)

      timestamps()
    end
    create index(:shopping_list_notes, [:shopping_item_id])
    create index(:shopping_list_notes, [:ingredient_id])
  end
end
