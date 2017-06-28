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
      time: meal.time}
  end
end
