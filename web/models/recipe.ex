defmodule Alastair.Recipe do
  use Alastair.Web, :model

  schema "recipes" do
    field :name, :string
    field :description, :string
    field :person_count, :integer
    field :instructions, :string
    belongs_to :database, Alastair.Database

    many_to_many :meals, Alastair.Meal, join_through: Alastair.MealRecipe
    many_to_many :ingredients, Alastair.Ingredient, join_through: Alastair.RecipeIngredient

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:name, :description, :person_count, :instructions])
    |> validate_required([:name, :description, :person_count, :instructions])
  end
end
