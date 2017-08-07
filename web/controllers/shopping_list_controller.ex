defmodule Alastair.ShoppingListController do
  use Alastair.Web, :controller

  alias Alastair.Event
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
        IO.inspect(ri)
        IO.inspect(item)
        Float.ceil(ri.real_quantity / item.buying_quantity)
      end
    end
  end

  defp choose_shopping_item(shopping_items, ri) do
    shopping_items
    |> Enum.filter(fn(x) -> x.mapped_ingredient_id == ri.ingredient_id end)
    |> Enum.sort(fn(a, b) -> a.price > b.price end)
    |> Enum.at(-1)
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
    |> Enum.map(fn(x) -> Map.put(x.recipe, :real_person_count, x.person_count) end)   # Carry the person count into the recipe
    |> Enum.map(fn(recipe) -> multiply_person_count(recipe) end)                      # Multiply the person count into the recipe_ingredients
    |> Enum.reduce([], fn(x, acc) -> Enum.concat(acc, x.recipes_ingredients) end)     # Join the recipes_ingredients into one big list, discard all meal-related information
    |> Enum.reduce(%{}, fn(ri, acc) -> Map.update(acc, ri.ingredient_id, ri,          # Update the map to either start with the current value
      fn(old) -> Map.update(old, :real_quantity, 0, fn(x) -> x + ri.real_quantity end) end) # Or, when the key is already present, to update that ri's real quantity
    end)

    # Fetch shopping_items for those ris from db
    shopping_items = from(p in Alastair.ShoppingItem,
      where: p.shop_id == ^event.shop_id and p.mapped_ingredient_id in ^Map.keys(ingredients),
      preload: [:buying_measurement]) 
    |> Repo.all 

    # For each of the ri, add a shopping_item based on a choice function and multiply up the price
    ingredients = Map.values(ingredients)
    |> Enum.map(fn(ri) -> 
      item = choose_shopping_item(shopping_items, ri)
      count = calc_item_count(item, ri)

      ri
      |> Map.put(:shopping_item, item)
      |> Map.put(:item_count, count)
      |> Map.put(:item_quantity, count * item.buying_quantity)
      |> Map.put(:item_price, count * item.price)
    end)
    |> IO.inspect

    send_resp(conn, :no_content, "")
  end

end
