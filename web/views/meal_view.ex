defmodule Alastair.MealView do
  use Alastair.Web, :view
  import Alastair.Helper

  def render("index.json", %{meals: meals}) do
    %{data: render_many(meals, Alastair.MealView, "meal.json")}
  end

  def render("show.json", %{meal: meal}) do
    %{data: render_one(meal, Alastair.MealView, "meal.json")}
  end

  def render("meal.json", %{meal: meal}) do
    %{id: meal.id,
      name: meal.name,
      time: meal.time,
      recipes: render_assoc_many(meal.meals_recipes, Alastair.MealView, "meal_recipe.json")  
      }
  end

  def render("meal_recipe.json", %{meal: meal_recipe}) do
    %{person_count: meal_recipe.person_count,
      recipe: render_assoc_one(meal_recipe.recipe, Alastair.RecipeView, "recipe.json"),
      recipe_id: meal_recipe.recipe_id
    }
  end
end
