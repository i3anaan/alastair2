defmodule Alastair.MealController do
  use Alastair.Web, :controller

  alias Alastair.Meal
  alias Alastair.MealRecipe

  def index(conn, %{"event_id" => event_id}) do
    meals = from(p in Meal, 
      where: p.event_id == ^event_id,
      preload: [{:meals_recipes, [:recipe]}])
    |> Repo.all

    render(conn, "index.json", meals: meals)
  end

  def create(conn, %{"meal" => meal_params, "event_id" => event_id}) do
    # TODO check if event exists
    # TODO check if user has access rights
    changeset = Meal.changeset(%Meal{}, Map.put(meal_params, "event_id", event_id))

    case Repo.insert(changeset) do
      {:ok, meal} ->
        meal = Repo.preload(meal, [{:meals_recipes, [:recipe]}], force: true)

        conn
        |> put_status(:created)
        |> put_resp_header("location", event_meal_path(conn, :show, meal.event_id, meal))
        |> render("show.json", meal: meal)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id, "event_id" => event_id}) do
    # Use complicated syntax to make sure you can not escalade privileges
    meal = from(p in Meal, where: p.id == ^id and p.event_id == ^event_id) |> Repo.one!
    |> Repo.preload([{:meals_recipes, [{:recipe, [{:recipes_ingredients, [{:ingredient, [:default_measurement]}]}]}]}])

    # TODO process item count
    meals_recipes = meal.meals_recipes
    |> Enum.map(fn(mr) -> 
      recipes_ingredients = mr.recipe.recipes_ingredients
      |> Enum.map(fn(ri) ->
        ri
        |> Map.put(:item_quantity, ri.quantity * (mr.person_count / mr.recipe.person_count))
      end)

      Map.update!(mr, :recipe, fn(recipe) -> Map.put(recipe, :recipes_ingredients, recipes_ingredients) end)
    end)
    meal = Map.put(meal, :meals_recipes, meals_recipes)

    render(conn, "show.json", meal: meal)
  end

  def update(conn, %{"id" => id, "meal" => meal_params, "event_id" => event_id}) do
    # TODO check if user has access rights
    meal = from(p in Meal, 
      where: p.id == ^id and p.event_id == ^event_id,
      preload: [:meals_recipes])
    |> Repo.one!
    changeset = Meal.changeset(meal, meal_params)

    case Repo.update(changeset) do
      {:ok, meal} ->

        meal = Repo.preload(meal, [{:meals_recipes, [:recipe]}])

        render(conn, "show.json", meal: meal)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id, "event_id" => event_id}) do
    from(p in MealRecipe, where: p.meal_id == ^id) |> Repo.delete_all
    from(p in Meal, where: p.id == ^id and p.event_id == ^event_id) |> Repo.one! |> Repo.delete!

    send_resp(conn, :no_content, "")
  end
end
