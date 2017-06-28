defmodule Alastair.IngredientControllerTest do
  use Alastair.ConnCase

  alias Alastair.Ingredient
  @valid_attrs %{description: "some content", name: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, ingredient_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    ingredient = Repo.insert! %Ingredient{}
    conn = get conn, ingredient_path(conn, :show, ingredient)
    assert json_response(conn, 200)["data"] == %{"id" => ingredient.id,
      "name" => ingredient.name,
      "description" => ingredient.description,
      "default_measurement_id" => ingredient.default_measurement_id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, ingredient_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, ingredient_path(conn, :create), ingredient: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Ingredient, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, ingredient_path(conn, :create), ingredient: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    ingredient = Repo.insert! %Ingredient{}
    conn = put conn, ingredient_path(conn, :update, ingredient), ingredient: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Ingredient, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    ingredient = Repo.insert! %Ingredient{}
    conn = put conn, ingredient_path(conn, :update, ingredient), ingredient: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    ingredient = Repo.insert! %Ingredient{}
    conn = delete conn, ingredient_path(conn, :delete, ingredient)
    assert response(conn, 204)
    refute Repo.get(Ingredient, ingredient.id)
  end
end
