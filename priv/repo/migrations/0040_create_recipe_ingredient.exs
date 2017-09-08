defmodule Alastair.Repo.Migrations.CreateRecipeIngredient do
  use Ecto.Migration

  def change do
    create table(:recipes_ingredients) do
      add :quantity, :float
      add :comment, :string
      add :recipe_id, references(:recipes, on_delete: :delete_all)
      add :ingredient_id, references(:ingredients, on_delete: :delete_all)
    end
    create index(:recipes_ingredients, [:recipe_id])
    create index(:recipes_ingredients, [:ingredient_id])

  end
end
