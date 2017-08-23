defmodule Alastair.RecipeView do
  use Alastair.Web, :view
  import Alastair.Helper

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
      avg_review: recipe.avg_review,
      published: recipe.published,
      created_by: recipe.created_by,
      version: recipe.version,
      recipes_ingredients: render_assoc_many(recipe.recipes_ingredients, Alastair.RecipeView, "recipe_ingredient.json")
    }
  end

  def render("recipe_ingredient.json", %{recipe: recipe_ingredient}) do
    %{quantity: recipe_ingredient.quantity,
      comment: recipe_ingredient.comment,
      ingredient: render_assoc_one(recipe_ingredient.ingredient, Alastair.IngredientView, "ingredient.json"),
      ingredient_id: recipe_ingredient.ingredient_id
    }
  end
end
