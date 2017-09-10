defmodule Alastair.ShoppingListView do
  use Alastair.Web, :view
  import Alastair.Helper

  def render("list.json", %{items: items, unmapped: unmapped, accumulates: accumulates}) do
    %{data: %{
      mapped: render_many(items, Alastair.ShoppingListView, "ingredient.json"),
      unmapped: render_many(unmapped, Alastair.ShoppingListView, "unmapped.json"),
      accumulates: render_one(accumulates, Alastair.ShoppingListView, "accumulates.json")
    }}
  end

  def render("unmapped.json", %{shopping_list: ri}) do
    %{ingredient_id: ri.ingredient_id,
      ingredient: render_assoc_one(ri.ingredient, Alastair.IngredientView, "ingredient.json"),
      note: render_assoc_one(ri.note, Alastair.ShoppingListView, "note.json"),
      calculated_quantity: ri.real_quantity
    }
  end

  def render("ingredient.json", %{shopping_list: ri}) do
    %{ingredient_id: ri.ingredient_id,
      ingredient: render_assoc_one(ri.ingredient, Alastair.IngredientView, "ingredient.json"),
      items: render_assoc_many(ri.items, Alastair.ShoppingListView, "item.json"),
      chosen_item: render_assoc_one(ri.chosen_item, Alastair.ShoppingListView, "item.json"),
      note: render_assoc_one(ri.note, Alastair.ShoppingListView, "note.json"),
      calculated_quantity: ri.real_quantity,
      best_price: ri.best_price,
      chosen_price: ri.chosen_item.item_price,
      used_in_meals: ri.used_in_meals
    }
  end

  def render("accumulates.json", %{shopping_list: acc}) do
    %{count: acc.count,
      price: acc.price
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

  def render("note.json", %{shopping_list: note}) do
    %{ticked: note.ticked,
      bought: note.bought,
      shopping_item_id: note.shopping_item_id
    }
  end
end
