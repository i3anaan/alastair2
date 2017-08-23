defmodule Alastair.RecipeIngredient do
  use Alastair.Web, :model

  schema "recipes_ingredients" do
    field :quantity, :float
    field :comment, :string
    belongs_to :recipe, Alastair.Recipe
    belongs_to :ingredient, Alastair.Ingredient
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:quantity, :comment, :recipe_id, :ingredient_id])
    |> validate_required([:quantity, :recipe_id, :ingredient_id])
    |> validate_length(:comment, max: 100)
    |> foreign_key_constraint(:recipe_id)
    |> foreign_key_constraint(:ingredient_id)
    |> validate_number(:quantity, greater_than: 0)
  end
end
