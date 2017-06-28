defmodule Alastair.RecipeIngredientTest do
  use Alastair.ModelCase

  alias Alastair.RecipeIngredient

  @valid_attrs %{quantity: "120.5"}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = RecipeIngredient.changeset(%RecipeIngredient{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = RecipeIngredient.changeset(%RecipeIngredient{}, @invalid_attrs)
    refute changeset.valid?
  end
end
