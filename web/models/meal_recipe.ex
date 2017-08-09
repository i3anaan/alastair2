defmodule Alastair.MealRecipe do
  use Alastair.Web, :model

  schema "meals_recipes" do
    field :person_count, :integer
    belongs_to :meal, Alastair.Meal
    belongs_to :recipe, Alastair.Recipe
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:person_count, :meal_id, :recipe_id])
    |> validate_required([:person_count, :meal_id, :recipe_id])
    |> foreign_key_constraint(:meal_id)
    |> foreign_key_constraint(:recipe_id)
    |> validate_number(:person_count, greater_than: 0)
  end
end
