defmodule Alastair.ShoppingListController do
  use Alastair.Web, :controller

  alias Alastair.Meal
  alias Alastair.ShoppingListNote

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

      # Also fetch shopping-list notes in case there are some
      shopping_list_notes = from(p in Alastair.ShoppingListNote,
        where: p.event_id == ^event_id and p.ingredient_id in ^Map.keys(ingredients))
      |> Repo.all

      # For each ri, find all suitable shopping items and calculate price, buying quantity, etc for each of these items
      # Sort them ascending by price, so the best option is always first
      # Also copy the best price straight into the ri
      {ingredients, unmapped} = Map.values(ingredients)
      |> Enum.map(fn(ri) -> 
        note = Enum.find(shopping_list_notes, nil, fn(x) -> x.ingredient_id == ri.ingredient_id end)

        items = shopping_items 
        |> Enum.filter(fn(x) -> x.mapped_ingredient_id == ri.ingredient_id end) # Filter only fitting shopping items
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

        # The best item is the cheapest one
        cheapest_item = case length(items) do
          0 -> %{item_price: 0}
          _ -> hd(items)
        end

        # Except we have one stored in the note
        best_item = if note do
          Enum.find(items, cheapest_item, fn(item) -> item.shopping_item_id == note.shopping_item_id end)
        else
          cheapest_item
        end

        ri
        |> Map.put(:items, items)
        |> Map.put(:best_price, best_item.item_price)
        |> Map.put(:chosen_item, best_item) # TODO implement option to choose mapping for ingredients
        |> Map.put(:note, note)
      end)
      |> Enum.reduce({[], []}, fn(i, {mapped, unmapped}) -> # Split off unmapped ingredients
        if Map.get(i.chosen_item, :shopping_item_id, nil) != nil do
          {mapped ++ [i], unmapped}
        else
          {mapped, unmapped ++ [i]}
        end
      end)

      accumulates = Enum.reduce(ingredients, %{count: 0, price: 0}, fn(ingredient, acc) ->
        acc
        |> Map.update!(:count, &(&1 + 1))
        |> Map.update!(:price, &(&1 + ingredient.best_price))
      end)


      render(conn, "list.json", items: ingredients, unmapped: unmapped, accumulates: accumulates)
    end
  end

  def put_note(conn, %{"event_id" => event_id, "ingredient_id" => ingredient_id, "note" => note_params}) do
    ingredient_id = case Integer.parse(ingredient_id) do
      {num, _} -> num
      _ -> nil
    end
    event = Alastair.EventController.get_event(event_id)

    if ingredient_id != nil && event != nil do
      changeset = case Repo.get_by(ShoppingListNote, event_id: event_id, ingredient_id: ingredient_id) do
        nil -> %ShoppingListNote{event_id: event_id, ingredient_id: ingredient_id}
        note -> note
      end
      |> ShoppingListNote.changeset(note_params)

      case Repo.insert_or_update(changeset) do
        {:ok, note} ->
          conn
          |> send_resp(:ok, "")
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:not_found)
      |> render(Alastair.ErrorView, "error.json", message: "Event or ingredient not found")
    end

  end

end
