defmodule Alastair.Repo.Migrations.CreateMealRecipe do
  use Ecto.Migration

  def change do
    create table(:meals_recipes) do
      add :person_count, :integer
      add :meal_id, references(:meals, on_delete: :nothing)
      add :recipe_id, references(:recipes, on_delete: :nothing)
    end
    create index(:meals_recipes, [:meal_id])
    create index(:meals_recipes, [:recipe_id])

  end
end
