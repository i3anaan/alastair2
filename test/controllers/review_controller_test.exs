defmodule Alastair.ReviewControllerTest do
  use Alastair.ConnCase

  alias Alastair.Review
  alias Alastair.Recipe
  @valid_attrs %{rating: 4, review: "some content"}
  @invalid_attrs %{rating: -1, review: "negative review"}
  @user_id "asd123"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    recipe = Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}

    conn = get conn, recipe_review_path(conn, :index, recipe)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    recipe = Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}
    review = Repo.insert! %Review{rating: 4, review: "some content", user_id: @user_id, recipe_id: recipe.id}
    conn = get conn, recipe_review_path(conn, :show, recipe, review)
    assert json_response(conn, 200)["data"] |> map_inclusion(%{"id" => review.id,
      "rating" => review.rating,
      "review" => review.review})
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    recipe = Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}
    assert_error_sent 404, fn ->
      get conn, recipe_review_path(conn, :show, recipe, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    recipe = Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}
    conn = post conn, recipe_review_path(conn, :create, recipe), review: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Review, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    recipe = Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}
    conn = post conn, recipe_review_path(conn, :create, recipe), review: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    recipe = Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}
    review = Repo.insert! %Review{recipe: recipe, rating: 1, review: "some other content", user_id: @user_id}
    conn = put conn, recipe_review_path(conn, :update, recipe, review), review: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Review, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    recipe = Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}
    review = Repo.insert! %Review{recipe: recipe, rating: 1, review: "some other content", user_id: @user_id}
    conn = put conn, recipe_review_path(conn, :update, recipe, review), review: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    recipe = Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}
    review = Repo.insert! %Review{recipe: recipe, rating: 1, review: "some other content", user_id: @user_id}    
    conn = delete conn, recipe_review_path(conn, :delete, recipe, review)
    assert response(conn, 204)
    refute Repo.get(Review, review.id)
  end
end
