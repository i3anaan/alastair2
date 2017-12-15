defmodule Alastair.Repo.Migrations.CreateMealRecipe do
  use Ecto.Migration

  def change do
    create table(:meals_recipes) do
      add :person_count, :integer
      add :meal_id, references(:meals, on_delete: :delete_all)
      add :recipe_id, references(:recipes, on_delete: :delete_all)
    end
    create index(:meals_recipes, [:meal_id])
    create index(:meals_recipes, [:recipe_id])

  end
end
