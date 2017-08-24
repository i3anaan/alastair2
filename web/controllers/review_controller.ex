defmodule Alastair.ReviewController do
  use Alastair.Web, :controller

  alias Alastair.Review

  def index(conn, %{"recipe_id" => recipe_id}) do
    reviews = from(p in Review, where: p.recipe_id == ^recipe_id) |> Repo.all
    render(conn, "index.json", reviews: reviews)
  end

  def create(conn, %{"review" => review_params, "recipe_id" => recipe_id}) do
    review = from(p in Review, where: p.recipe_id == ^recipe_id and p.user_id == ^conn.assigns.user.id) |> Repo.one
    
    if review == nil do
      recipe = Repo.get(Alastair.Recipe, recipe_id)

      if recipe != nil && recipe.published do
        if recipe.created_by != conn.assigns.user.id do
          changeset = Review.changeset(%Review{}, 
            review_params
            |> Map.put("recipe_id", recipe_id)
            |> Map.put("user_id", conn.assigns.user.id)
          )

          case Repo.insert(changeset) do
            {:ok, review} ->
              Alastair.RecipeController.update_avg_review(recipe_id)

              conn
              |> put_status(:created)
              |> put_resp_header("location", recipe_review_path(conn, :show, recipe_id, review))
              |> render("show.json", review: review)
            {:error, changeset} ->
              conn
              |> put_status(:unprocessable_entity)
              |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
          end
        else
          conn
          |> put_status(:forbidden)
          |> render(Alastair.ErrorView, "error.json", message: "You can not review your own recipe")
        end
      else
        conn
        |> put_status(:not_found)
        |> render(Alastair.ErrorView, "error.json", message: "This recipe is either non-existing or not published")
      end
    else
      conn
      |> put_status(:conflict)
      |> render(Alastair.ErrorView, "error.json", message: "You already reviewed this recipe")
    end
  end

  def show(conn, %{"id" => id}) do
    review = Repo.get!(Review, id)
    render(conn, "show.json", review: review)
  end

  def update(conn, %{"id" => id, "review" => review_params, "recipe_id" => recipe_id}) do
    review = Repo.get!(Review, id)
    if(review.user_id == conn.assigns.user.id) do
      changeset = Review.changeset(review, review_params)

      case Repo.update(changeset) do
        {:ok, review} ->
          Alastair.RecipeController.update_avg_review(recipe_id)
          render(conn, "show.json", review: review)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:forbidden)
      |> render(Alastair.ErrorView, "error.json", message: "You are only allowed to edit your own reviews")
    end
  end

  def delete(conn, %{"id" => id, "recipe_id" => recipe_id}) do
    review = Repo.get!(Review, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    if(review.user_id == conn.assigns.user.id) do
      Repo.delete!(review)
      Alastair.RecipeController.update_avg_review(recipe_id)
      
      send_resp(conn, :no_content, "")
    else
      conn
      |> put_status(:forbidden)
      |> render(Alastair.ErrorView, "403.json", message: "You are only allowed to delete your own reviews")
    end
  end
end
