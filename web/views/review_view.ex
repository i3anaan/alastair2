defmodule Alastair.ReviewView do
  use Alastair.Web, :view

  def render("index.json", %{reviews: reviews}) do
    %{data: render_many(reviews, Alastair.ReviewView, "review.json")}
  end

  def render("show.json", %{review: review}) do
    %{data: render_one(review, Alastair.ReviewView, "review.json")}
  end

  def render("review.json", %{review: review}) do
    %{id: review.id,
      rating: review.rating,
      review: review.review,
      recipe_id: review.recipe_id}
  end
end
