defmodule Alastair.MealControllerTest do
  use Alastair.ConnCase

  alias Alastair.Meal
  @event "DevelopYourself3"
  @meal_time Ecto.Time.cast!(%{hour: 14, min: 0, sec: 0})
  @meal_date Ecto.Date.cast!(%{year: 2010, month: 01, day: 22})
  @valid_attrs %{name: "some content", time: %{hour: 14, min: 0, sec: 0}, date: %{year: 2010, month: 01, day: 22}}
  @invalid_attrs %{}

  setup %{conn: conn} do
    Alastair.EventController.get_event(@event)
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, event_meal_path(conn, :index, @event)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    recipe = Repo.insert! %Alastair.Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}
    meal = Repo.insert! %Meal{name: "some content", time: @meal_time, date: @meal_date, event_id: @event}
    meal_recipe = Repo.insert! %Alastair.MealRecipe{person_count: 10, meal: meal, recipe: recipe}

    conn = get conn, event_meal_path(conn, :show, @event, meal)
    assert json_response(conn, 200)["data"] |> map_inclusion(%{"id" => meal.id,
      "name" => meal.name})
    assert json_response(conn, 200)["data"]["time"] |> Ecto.Time.cast! == @meal_time
    assert json_response(conn, 200)["data"]["meals_recipes"] |> is_list
    assert json_response(conn, 200)["data"]["meals_recipes"] |> Enum.any?(fn(mr) -> mr["recipe_id"] == meal_recipe.recipe_id end)
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, event_meal_path(conn, :show, @event, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, event_meal_path(conn, :create, @event), meal: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Meal, %{name: "some content", event_id: @event})
  end

  test "creates and renders resource when data is valid and recipes are attached", %{conn: conn} do
    recipe = Repo.insert! %Alastair.Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}

    conn = post conn, event_meal_path(conn, :create, @event), meal: Map.put(@valid_attrs, :meals_recipes, [%{person_count: 20, recipe_id: recipe.id}])
    assert json_response(conn, 201)["data"]["id"]
    assert json_response(conn, 201)["data"]["meals_recipes"] |> is_list
    assert json_response(conn, 201)["data"]["meals_recipes"] |> Enum.any?(fn(mr) -> mr["recipe_id"] == recipe.id end)
    assert Repo.get_by(Meal, %{name: "some content", event_id: @event})
  end

  test "creates and renders resource when data is valid and an empty list of recipes is attached", %{conn: conn} do
    conn = post conn, event_meal_path(conn, :create, @event), meal: Map.put(@valid_attrs, :meals_recipes, [])
    assert json_response(conn, 201)["data"]["id"]
    assert json_response(conn, 201)["data"]["meals_recipes"] == []
    assert Repo.get_by(Meal, %{name: "some content", event_id: @event})
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, event_meal_path(conn, :create, @event), meal: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not create resource when errors in meals_recipes", %{conn: conn} do
    recipe = Repo.insert! %Alastair.Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}

    conn = post conn, event_meal_path(conn, :create, @event), meal: Map.put(@valid_attrs, :meals_recipes, [%{person_count: -1, recipe_id: recipe.id}])
    assert json_response(conn, 422)["errors"]["meals_recipes"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    meal = Repo.insert! %Meal{name: "some other content", time: @meal_time, date: @meal_date, event_id: @event}
    conn = put conn, event_meal_path(conn, :update, @event, meal), meal: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Meal, %{name: "some content", event_id: @event})
  end  

  test "updates and renders chosen resource when data is valid and recipes are attached", %{conn: conn} do
    recipe = Repo.insert! %Alastair.Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}
    meal = Repo.insert! %Meal{name: "some other content", time: @meal_time, date: @meal_date, event_id: @event}
    Repo.insert! %Alastair.MealRecipe{person_count: 10, meal: meal, recipe: recipe}

    conn = put conn, event_meal_path(conn, :update, @event, meal), meal: Map.put(@valid_attrs, :meals_recipes, [%{person_count: 20, recipe_id: recipe.id}])
    assert json_response(conn, 200)["data"]["id"]
    assert json_response(conn, 200)["data"]["meals_recipes"] |> is_list
    assert json_response(conn, 200)["data"]["meals_recipes"] |> Enum.any?(fn(mr) -> mr["recipe_id"] == recipe.id && mr["person_count"] == 20 end)
    assert Repo.get_by(Meal, %{name: "some content", event_id: @event})
  end

  test "updates and renders chosen resource when data is valid and empty list of recipes is attached", %{conn: conn} do
    recipe = Repo.insert! %Alastair.Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}
    meal = Repo.insert! %Meal{name: "some other content", time: @meal_time, date: @meal_date, event_id: @event}
    Repo.insert! %Alastair.MealRecipe{person_count: 10, meal: meal, recipe: recipe}

    conn = put conn, event_meal_path(conn, :update, @event, meal), meal: Map.put(@valid_attrs, :meals_recipes, [])
    assert json_response(conn, 200)["data"]["id"]
    assert json_response(conn, 200)["data"]["meals_recipes"] == []
    assert Repo.get_by(Meal, %{name: "some content", event_id: @event})
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    meal = Repo.insert! %Meal{name: "some other content", time: @meal_time, event_id: @event}
    conn = put conn, event_meal_path(conn, :update, @event, meal), meal: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not update chosen resource when errors in meals_recipes", %{conn: conn} do
    recipe = Repo.insert! %Alastair.Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}
    meal = Repo.insert! %Meal{name: "some other content", time: @meal_time, date: @meal_date, event_id: @event}
    Repo.insert! %Alastair.MealRecipe{person_count: 10, meal: meal, recipe: recipe}

    conn = put conn, event_meal_path(conn, :update, @event, meal), meal: Map.put(@valid_attrs, :meals_recipes, [%{person_count: -20, recipe_id: recipe.id}])
    assert json_response(conn, 422)["errors"]["meals_recipes"]
  end


  test "deletes chosen resource", %{conn: conn} do
    meal = Repo.insert! %Meal{name: "some other content", time: @meal_time, date: @meal_date, event_id: @event}
    conn = delete conn, event_meal_path(conn, :delete, @event, meal)
    assert response(conn, 204)
    refute Repo.get(Meal, meal.id)
  end
end
