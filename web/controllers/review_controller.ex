defmodule Alastair.ReviewController do
  use Alastair.Web, :controller

  alias Alastair.Review

  def index(conn, _params) do
    reviews = Repo.all(Review)
    render(conn, "index.json", reviews: reviews)
  end

  def create(conn, %{"review" => review_params}) do
    changeset = Review.changeset(%Review{}, review_params)

    case Repo.insert(changeset) do
      {:ok, review} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", recipe_review_path(conn, :show, review.recipe_id, review))
        |> render("show.json", review: review)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    review = Repo.get!(Review, id)
    render(conn, "show.json", review: review)
  end

  def update(conn, %{"id" => id, "review" => review_params}) do
    review = Repo.get!(Review, id)
    changeset = Review.changeset(review, review_params)

    case Repo.update(changeset) do
      {:ok, review} ->
        render(conn, "show.json", review: review)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    review = Repo.get!(Review, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(review)

    send_resp(conn, :no_content, "")
  end
end
