defmodule Alastair.MealControllerTest do
  use Alastair.ConnCase

  alias Alastair.Meal
  @valid_attrs %{name: "some content", time: %{day: 17, hour: 14, min: 0, month: 4, sec: 0, year: 2010}}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, meal_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    meal = Repo.insert! %Meal{}
    conn = get conn, meal_path(conn, :show, meal)
    assert json_response(conn, 200)["data"] == %{"id" => meal.id,
      "name" => meal.name,
      "time" => meal.time}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, meal_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, meal_path(conn, :create), meal: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Meal, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, meal_path(conn, :create), meal: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    meal = Repo.insert! %Meal{}
    conn = put conn, meal_path(conn, :update, meal), meal: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Meal, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    meal = Repo.insert! %Meal{}
    conn = put conn, meal_path(conn, :update, meal), meal: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    meal = Repo.insert! %Meal{}
    conn = delete conn, meal_path(conn, :delete, meal)
    assert response(conn, 204)
    refute Repo.get(Meal, meal.id)
  end
end
