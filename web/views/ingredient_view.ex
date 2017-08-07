defmodule Alastair.IngredientView do
  use Alastair.Web, :view
  import Alastair.Helper

  def render("index.json", %{ingredients: ingredients}) do
    %{data: render_many(ingredients, Alastair.IngredientView, "ingredient.json")}
  end

  def render("show.json", %{ingredient: ingredient}) do
    %{data: render_one(ingredient, Alastair.IngredientView, "ingredient.json")}
  end

  def render("ingredient.json", %{ingredient: ingredient}) do
    %{id: ingredient.id,
      name: ingredient.name,
      description: ingredient.description,
      default_measurement: render_assoc_one(ingredient.default_measurement, Alastair.MeasurementView, "measurement.json"),
      default_measurement_id: ingredient.default_measurement_id
    }
  end
end
 