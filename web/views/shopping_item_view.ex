defmodule Alastair.ShoppingItemView do
  use Alastair.Web, :view

  def render("index.json", %{shopping_items: shopping_items}) do
    %{data: render_many(shopping_items, Alastair.ShoppingItemView, "shopping_item.json")}
  end

  def render("show.json", %{shopping_item: shopping_item}) do
    %{data: render_one(shopping_item, Alastair.ShoppingItemView, "shopping_item.json")}
  end

  def render("shopping_item.json", %{shopping_item: shopping_item}) do
    %{id: shopping_item.id,
      comment: shopping_item.comment,
      buying_measurement_id: shopping_item.buying_measurement_id,
      buying_quantity: shopping_item.buying_quantity,
      mapped_ingredient_id: shopping_item.mapped_ingredient_id,
      price: shopping_item.price,
      shop_id: shopping_item.shop_id}
  end
end
