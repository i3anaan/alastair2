defmodule Alastair.MealRecipeTest do
  use Alastair.ModelCase

  alias Alastair.MealRecipe

  @valid_attrs %{person_count: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = MealRecipe.changeset(%MealRecipe{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = MealRecipe.changeset(%MealRecipe{}, @invalid_attrs)
    refute changeset.valid?
  end
end
