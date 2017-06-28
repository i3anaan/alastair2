defmodule Alastair.RecipeControllerTest do
  use Alastair.ConnCase

  alias Alastair.Recipe
  @valid_attrs %{description: "some content", instructions: "some content", name: "some content", person_count: 42}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, recipe_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    recipe = Repo.insert! %Recipe{}
    conn = get conn, recipe_path(conn, :show, recipe)
    assert json_response(conn, 200)["data"] == %{"id" => recipe.id,
      "name" => recipe.name,
      "description" => recipe.description,
      "person_count" => recipe.person_count,
      "instructions" => recipe.instructions,
      "database_id" => recipe.database_id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, recipe_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, recipe_path(conn, :create), recipe: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Recipe, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, recipe_path(conn, :create), recipe: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    recipe = Repo.insert! %Recipe{}
    conn = put conn, recipe_path(conn, :update, recipe), recipe: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Recipe, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    recipe = Repo.insert! %Recipe{}
    conn = put conn, recipe_path(conn, :update, recipe), recipe: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    recipe = Repo.insert! %Recipe{}
    conn = delete conn, recipe_path(conn, :delete, recipe)
    assert response(conn, 204)
    refute Repo.get(Recipe, recipe.id)
  end
end
