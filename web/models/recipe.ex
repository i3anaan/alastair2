defmodule Alastair.Recipe do
  use Alastair.Web, :model

  schema "recipes" do
    field :name, :string
    field :description, :string
    field :person_count, :integer
    field :instructions, :string
    field :avg_review, :float

    many_to_many :meals, Alastair.Meal, join_through: Alastair.MealRecipe
    many_to_many :ingredients, Alastair.Ingredient, join_through: Alastair.RecipeIngredient
    has_many :recipes_ingredients, Alastair.RecipeIngredient
    has_many :reviews, Alastair.Review

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :person_count, :instructions])
    |> validate_required([:name, :person_count, :instructions])
  end
end
