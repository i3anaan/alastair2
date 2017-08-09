defmodule Alastair.ShoppingListController do
  use Alastair.Web, :controller

  alias Alastair.Meal

  defp multiply_person_count(recipe) do
    factor = recipe.real_person_count / recipe.person_count
    %{recipe | recipes_ingredients: Enum.map(recipe.recipes_ingredients, fn(ri) -> Map.put(ri, :real_quantity, ri.quantity*factor) end)}
  end

  defp calc_item_count(item, ri) do
    if item==nil do
      0
    else
      if item.flexible_amount do
        ri.real_quantity / item.buying_quantity
      else
        Float.ceil(ri.real_quantity / item.buying_quantity)
      end
    end
  end

  def shopping_list(conn, %{"event_id" => event_id}) do
    event = Alastair.EventController.get_event(event_id)

    # Fetch all the meals including everything down to their ingredients from db
    meals = from(p in Meal, 
      where: p.event_id == ^event_id,
      preload: [{:meals_recipes, [{:recipe, [{:recipes_ingredients, [{:ingredient, [:default_measurement]}]}]}]}]) # lol
    |> Repo.all
    
    # Map the meals down to recipes_ingredients
    ingredients = meals 
    |> Enum.reduce([], fn(x, acc) -> Enum.concat(acc, x.meals_recipes) end)           # Reduce to meals_recipes
    |> Enum.map(fn(x) -> 
      x.recipe
      |> Map.put(:real_person_count, x.person_count)                                  # Carry the person count into the recipe_ingredient
      |> multiply_person_count                                                        # Multiply the person count into the recipe_ingredient
    end)   
    |> Enum.reduce([], fn(x, acc) -> Enum.concat(acc, x.recipes_ingredients) end)     # Join the recipes_ingredients into one big list, discard all meal-related information
    |> Enum.reduce(%{}, fn(ri, acc) -> Map.update(acc, ri.ingredient_id, ri,          # Update the map to either start with the current value
      fn(old) -> Map.update(old, :real_quantity, 0, fn(x) -> x + ri.real_quantity end) end) # Or, when the key is already present, to update that ri's real quantity
    end)

    # On empty map we are done
    if Enum.empty?(Map.keys(ingredients)) do
      render(conn, "list.json", items: [])
    else
      # Fetch shopping_items for those ris from db
      shopping_items = from(p in Alastair.ShoppingItem,
        where: p.shop_id == ^event.shop_id and p.mapped_ingredient_id in ^Map.keys(ingredients)) 
      |> Repo.all 

      # For each ri, find all suitable shopping items and calculate price, buying quantity, etc for each of these items
      # Sort them ascending by price, so the best option is always first
      # Also copy the best price straight into the ri
      ingredients = Map.values(ingredients)
      |> Enum.map(fn(ri) -> 
        items = shopping_items 
        |> Enum.filter(fn(x) -> x.mapped_ingredient_id == ri.ingredient_id end)
        |> Enum.map(fn(item) -> 
          count = calc_item_count(item, ri)
          %{}
          |> Map.put(:shopping_item, item)
          |> Map.put(:shopping_item_id, item.id)
          |> Map.put(:item_count, count)
          |> Map.put(:item_quantity, count * item.buying_quantity)
          |> Map.put(:item_price, count * item.price)
        end)
        |> Enum.sort(fn(a, b) -> a.item_price < b.item_price end)

        best_item = case length(items) do
          0 -> %{item_price: 0}
          _ -> hd(items)
        end

        ri
        |> Map.put(:items, items)
        |> Map.put(:best_price, best_item.item_price)
      end)



      render(conn, "list.json", items: ingredients)
    end
  end

end
