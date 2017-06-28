defmodule Alastair.RecipeIngredient do
  use Alastair.Web, :model

  schema "recipes_ingredients" do
    field :quantity, :float
    belongs_to :recipe, Alastair.Recipe
    belongs_to :ingredient, Alastair.Ingredient

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:quantity])
    |> validate_required([:quantity])
  end
end
