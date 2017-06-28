defmodule Alastair.RecipeTest do
  use Alastair.ModelCase

  alias Alastair.Recipe

  @valid_attrs %{description: "some content", instructions: "some content", name: "some content", person_count: 42}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Recipe.changeset(%Recipe{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Recipe.changeset(%Recipe{}, @invalid_attrs)
    refute changeset.valid?
  end
end
