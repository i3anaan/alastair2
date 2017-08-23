defmodule Alastair.IngredientController do
  use Alastair.Web, :controller
  
  import Alastair.Helper
  alias Alastair.Ingredient

  def index(conn, params) do
    ingredients = from(p in Ingredient,
            preload: [:default_measurement],
            order_by: :name)
    |> paginate(params)
    |> search(params)
    |> Repo.all


    render(conn, "index.json", ingredients: ingredients)
  end

  def create(conn, %{"ingredient" => ingredient_params}) do

    changeset = Ingredient.changeset(%Ingredient{}, ingredient_params)

    case Repo.insert(changeset) do
      {:ok, ingredient} ->
        ingredient = Repo.preload(ingredient, :default_measurement)
        conn
        |> put_status(:created)
        |> put_resp_header("location", ingredient_path(conn, :show, ingredient))
        |> render("show.json", ingredient: ingredient)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    ingredient = Repo.get!(Ingredient, id)
    render(conn, "show.json", ingredient: ingredient)
  end

  def update(conn, %{"id" => id, "ingredient" => ingredient_params}) do
    ingredient = Repo.get!(Ingredient, id)
    changeset = Ingredient.changeset(ingredient, ingredient_params)

    case Repo.update(changeset) do
      {:ok, ingredient} ->
        render(conn, "show.json", ingredient: ingredient)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    if conn.assigns.user.superadmin do
      ingredient = Repo.get!(Ingredient, id)

      from(p in Alastair.RecipeIngredient, where: p.ingredient_id == ^id) |> Repo.delete_all
      from(p in Alastair.ShoppingItem, where: p.mapped_ingredient_id == ^id) |> Repo.delete_all

      # Here we use delete! (with a bang) because we expect
      # it to always work (and if it does not, it will raise).
      Repo.delete!(ingredient)

      send_resp(conn, :no_content, "")
    else
      conn
      |> put_status(:forbidden)
      |> render(Alastair.ErrorView, "error.json", message: "You cannot delete ingredients")
    end
  end
end
