defmodule Alastair.RecipeController do
  use Alastair.Web, :controller

  alias Alastair.Recipe
  alias Alastair.RecipeIngredient

  def index(conn, _params) do
    recipes = Repo.all(Recipe)
    render(conn, "index.json", recipes: recipes)
  end

  defp create_recipe_ingredient(recipe_id, ingredient_id, quantity) do
    changeset = RecipeIngredient.changeset(%RecipeIngredient{}, %{recipe_id: recipe_id, ingredient_id: ingredient_id, quantity: quantity})
    # TODO add error handling
    Repo.insert!(changeset)
  end

  def create(conn, %{"recipe" => recipe_params}) do
    changeset = Recipe.changeset(%Recipe{}, recipe_params)

    case Repo.insert(changeset) do
      {:ok, recipe} ->

        if Map.get(recipe_params, "recipes_ingredients", nil) != nil do
          recipe_params["recipes_ingredients"]
          |> Enum.uniq_by(fn(x) -> x["ingredient_id"] end) # TODO merge duplicate ingredients into one
          |> Enum.map(fn(x) -> create_recipe_ingredient(recipe.id, x["ingredient_id"], x["quantity"]) end)
        end

        recipe = Repo.preload(recipe, [{:recipes_ingredients, [{:ingredient, [:default_measurement]}]}])

        conn
        |> put_status(:created)
        |> put_resp_header("location", recipe_path(conn, :show, recipe))
        |> render("show.json", recipe: recipe)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    recipe = Repo.get!(Recipe, id)
      |> Repo.preload([{:recipes_ingredients, [{:ingredient, [:default_measurement]}]}]) # Preload nested recipe_ingredient and ingredient and measurement
    render(conn, "show.json", recipe: recipe)
  end

  def update(conn, %{"id" => id, "recipe" => recipe_params}) do
    recipe = Repo.get!(Recipe, id)
    changeset = Recipe.changeset(recipe, recipe_params)

    case Repo.update(changeset) do
      {:ok, recipe} ->
        # Delete all ingredients and add all again
        if Map.get(recipe_params, "recipes_ingredients", nil) != nil do
          from(p in RecipeIngredient, where: p.recipe_id == ^recipe.id) |> Repo.delete_all

          recipe_params["recipes_ingredients"]
          |> Enum.uniq_by(fn(x) -> x["ingredient_id"] end) # TODO merge duplicate ingredients into one
          |> Enum.map(fn(x) -> create_recipe_ingredient(recipe.id, x["ingredient_id"], x["quantity"]) end)
        end

        recipe = Repo.preload(recipe, [{:recipes_ingredients, [{:ingredient, [:default_measurement]}]}])

        render(conn, "show.json", recipe: recipe)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    Repo.get!(Recipe, id) |> Repo.delete!

    from(p in RecipeIngredient, where: p.recipe_id == ^id) |> Repo.delete_all

    send_resp(conn, :no_content, "")
  end

  defp calc_avg_review(id) do
    tmp = from(p in Alastair.Review, where: p.recipe_id == ^id) 
    |> Repo.all
    |> Enum.reduce({0, 0}, fn(x, acc) -> {elem(acc, 0) + x.rating, elem(acc, 1) + 1} end)

    case elem(tmp, 1) do
      0 -> nil
      _ -> elem(tmp, 0) / elem(tmp, 1)
    end
  end

  def update_avg_review(id) do
    review = calc_avg_review(id)
    Repo.get!(Recipe, id)
    |> Ecto.Changeset.change(avg_review: review)
    |> Repo.update!
  end
end
