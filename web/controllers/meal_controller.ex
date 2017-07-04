defmodule Alastair.MealController do
  use Alastair.Web, :controller

  alias Alastair.Meal
  alias Alastair.MealRecipe

  def index(conn, %{"event_id" => event_id}) do
    meals = from(p in Meal, where: p.event_id == ^event_id) |> Repo.all

    render(conn, "index.json", meals: meals)
  end

  defp create_meal_recipe(recipe_id, meal_id, person_count) do
    changeset = MealRecipe.changeset(%MealRecipe{}, %{recipe_id: recipe_id, meal_id: meal_id, person_count: person_count})
    # TODO add error handling
    Repo.insert!(changeset)
  end

  def create(conn, %{"meal" => meal_params, "event_id" => event_id}) do
    # TODO check if event exists
    # TODO check if user has access rights
    changeset = Meal.changeset(%Meal{}, Map.put(meal_params, "event_id", event_id))

    case Repo.insert(changeset) do
      {:ok, meal} ->
        meal_params["recipes"]
        |> Enum.uniq_by(fn(x) -> x["recipe_id"] end)
        |> Enum.map(fn(x) -> create_meal_recipe(x["recipe_id"], meal.id, x["person_count"]) end)

        meal = Repo.preload(meal, [{:meals_recipes, [:recipe]}])

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

  def show(conn, %{"id" => id}) do
    meal = Repo.get!(Meal, id)
    |> Repo.preload([{:meals_recipes, [:recipe]}])

    render(conn, "show.json", meal: meal)
  end

  def update(conn, %{"id" => id, "meal" => meal_params}) do
    # TODO check if user has access rights
    meal = Repo.get!(Meal, id)
    changeset = Meal.changeset(meal, meal_params)

    case Repo.update(changeset) do
      {:ok, meal} ->

        from(p in MealRecipe, where: p.meal_id == ^meal.id) |> Repo.delete_all

        meal_params["recipes"]
        |> Enum.uniq_by(fn(x) -> x["recipe_id"] end)
        |> Enum.map(fn(x) -> create_meal_recipe(x["recipe_id"], meal.id, x["person_count"]) end)

        meal = Repo.preload(meal, [{:meals_recipes, [:recipe]}])

        render(conn, "show.json", meal: meal)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    Repo.get!(Meal, id) |> Repo.delete!

    from(p in MealRecipe, where: p.meal_id == ^id) |> Repo.delete_all

    send_resp(conn, :no_content, "")
  end
end
