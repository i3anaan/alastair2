defmodule Alastair.ReviewControllerTest do
  use Alastair.ConnCase

  alias Alastair.Review
  @valid_attrs %{rating: 42, review: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, review_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    review = Repo.insert! %Review{}
    conn = get conn, review_path(conn, :show, review)
    assert json_response(conn, 200)["data"] == %{"id" => review.id,
      "rating" => review.rating,
      "review" => review.review,
      "recipe_id" => review.recipe_id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, review_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, review_path(conn, :create), review: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Review, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, review_path(conn, :create), review: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    review = Repo.insert! %Review{}
    conn = put conn, review_path(conn, :update, review), review: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Review, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    review = Repo.insert! %Review{}
    conn = put conn, review_path(conn, :update, review), review: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    review = Repo.insert! %Review{}
    conn = delete conn, review_path(conn, :delete, review)
    assert response(conn, 204)
    refute Repo.get(Review, review.id)
  end
end
