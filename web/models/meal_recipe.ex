defmodule Alastair.MealRecipe do
  use Alastair.Web, :model

  schema "meals_recipes" do
    field :person_count, :integer
    belongs_to :meal, Alastair.Meal
    belongs_to :recipe, Alastair.Recipe

    timestamps()
  end

  @doc """
  Builds a changeset based on the `struct` and `params`.
  """
  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:person_count])
    |> validate_required([:person_count])
  end
end
