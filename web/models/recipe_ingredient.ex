defmodule Alastair.RecipeIngredient do
  use Alastair.Web, :model

  schema "recipes_ingredients" do
    field :quantity, :float
    belongs_to :recipe, Alastair.Recipe
    belongs_to :ingredient, Alastair.Ingredient
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:quantity, :recipe_id, :ingredient_id])
    |> validate_required([:quantity, :recipe_id, :ingredient_id])
  end
end
