defmodule Alastair.ShoppingListView do
  use Alastair.Web, :view
  import Alastair.Helper

  def render("list.json", %{items: items}) do
    %{data: render_many(items, Alastair.ShoppingListView, "list.json")}
  end

  def render("list.json", %{shopping_list: ri}) do
    %{ingredient_id: ri.ingredient_id,
      ingredient: render_assoc_one(ri.ingredient, Alastair.IngredientView, "ingredient.json"),
      items: render_many(ri.items, Alastair.ShoppingListView, "item.json"),
      calculated_quantity: ri.real_quantity,
      best_price: ri.best_price
    }
  end

  def render("item.json", %{shopping_list: item}) do
    %{shopping_item_id: item.shopping_item_id,
      shopping_item: render_assoc_one(item.shopping_item, Alastair.ShoppingItemView, "shopping_item.json"),
      item_count: item.item_count,
      item_price: item.item_price,
      item_buying_quantity: item.item_quantity
    }
  end
end
