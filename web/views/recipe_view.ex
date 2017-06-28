defmodule Alastair.RecipeView do
  use Alastair.Web, :view

  def render("index.json", %{recipes: recipes}) do
    %{data: render_many(recipes, Alastair.RecipeView, "recipe.json")}
  end

  def render("show.json", %{recipe: recipe}) do
    %{data: render_one(recipe, Alastair.RecipeView, "recipe.json")}
  end

  def render("recipe.json", %{recipe: recipe}) do
    %{id: recipe.id,
      name: recipe.name,
      description: recipe.description,
      person_count: recipe.person_count,
      instructions: recipe.instructions,
      database_id: recipe.database_id}
  end
end
