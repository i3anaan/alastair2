defmodule Alastair.ShoppingItemView do
  use Alastair.Web, :view
  import Alastair.Helper

  def render("index.json", %{shopping_items: shopping_items}) do
    %{data: render_many(shopping_items, Alastair.ShoppingItemView, "shopping_item.json")}
  end

  def render("show.json", %{shopping_item: shopping_item}) do
    %{data: render_one(shopping_item, Alastair.ShoppingItemView, "shopping_item.json")}
  end

  def render("shopping_item.json", %{shopping_item: shopping_item}) do
    %{id: shopping_item.id,
      name: shopping_item.name,
      comment: shopping_item.comment,
      buying_measurement_id: shopping_item.buying_measurement_id,
      buying_measurement: render_assoc_one(shopping_item.buying_measurement, Alastair.MeasurementView, "measurement.json"),
      buying_quantity: shopping_item.buying_quantity,
      flexible_amount: shopping_item.flexible_amount,
      mapped_ingredient_id: shopping_item.mapped_ingredient_id,
      mapped_ingredient: render_assoc_one(shopping_item.mapped_ingredient, Alastair.IngredientView, "ingredient.json"),
      price: shopping_item.price}
  end
end
