defmodule Alastair.MealView do
  use Alastair.Web, :view

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
      recipes:
        case Ecto.assoc_loaded?(meal.meals_recipes) do
          true -> render_many(meal.meals_recipes, Alastair.MealView, "meal_recipe.json");
          false -> nil;
        end    
      }
  end

  def render("meal_recipe.json", %{meal: meal_recipe}) do
    %{person_count: meal_recipe.person_count,
      recipe: render_one(meal_recipe.recipe, Alastair.RecipeView, "recipe.json"),
      recipe_id: meal_recipe.recipe_id
    }
  end
end
