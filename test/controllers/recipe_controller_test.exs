defmodule Alastair.RecipeControllerTest do
  use Alastair.ConnCase

  alias Alastair.Recipe
  @userid "asd123"
  @valid_attrs %{description: "some content", instructions: "some content", name: "some content", person_count: 42, published: false}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, recipe_path(conn, :index)
    assert json_response(conn, 200)["data"] == []

    Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "findme", person_count: 42, published: true}
    conn = get conn, recipe_path(conn, :index)
    assert json_response(conn, 200)["data"] != []
  end

  test "lists only entries which are published", %{conn: conn} do
    recipe1 = Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "notfindme", person_count: 42, published: false}
    recipe2 = Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "findme", person_count: 42, published: true}
    conn = get conn, recipe_path(conn, :index)
    assert json_response(conn, 200)["data"] |> Enum.any?(fn(x) -> x["name"] == recipe2.name end)
    refute json_response(conn, 200)["data"] |> Enum.any?(fn(x) -> x["name"] == recipe1.name end)
  end

  test "shows chosen resource", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    ingredient = Repo.insert! %Alastair.Ingredient{
      name: "Cream",
      description: "Milkproduct",
      default_measurement_id: ml.id
    }
    recipe = Repo.insert! %Recipe{description: "some content", instructions: "some content", name: "some content", person_count: 42}

    recipe_ingredient = Repo.insert! %Alastair.RecipeIngredient{
      recipe: recipe,
      ingredient: ingredient,
      quantity: 100.0
    }

    conn = get conn, recipe_path(conn, :show, recipe)
    assert json_response(conn, 200)["data"] |> map_inclusion(%{"id" => recipe.id,
      "name" => recipe.name,
      "description" => recipe.description,
      "person_count" => recipe.person_count,
      "instructions" => recipe.instructions})
    assert json_response(conn, 200)["data"]["recipes_ingredients"] != []
    assert json_response(conn, 200)["data"]["recipes_ingredients"] |> Enum.any?(fn(ri) -> 
      ri |> map_inclusion(%{"ingredient_id" => recipe_ingredient.ingredient_id, "quantity" => recipe_ingredient.quantity})
    end)
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

  test "creates and renders resource when data is valid and ingredients are attached", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    ingredient = Repo.insert! %Alastair.Ingredient{
      name: "Cream",
      description: "Milkproduct",
      default_measurement_id: ml.id
    }

    conn = post conn, recipe_path(conn, :create), recipe: Map.put(@valid_attrs, :recipes_ingredients, [%{ingredient_id: ingredient.id, quantity: 100.0}])
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Recipe, @valid_attrs)
    assert json_response(conn, 201)["data"]["recipes_ingredients"] != []
    assert json_response(conn, 201)["data"]["recipes_ingredients"] |> Enum.any?(fn(ri) -> 
      ri |> map_inclusion(%{"ingredient_id" => ingredient.id, "quantity" => 100.0})
    end)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, recipe_path(conn, :create), recipe: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    recipe = Repo.insert! %Recipe{created_by: @userid}
    conn = put conn, recipe_path(conn, :update, recipe), recipe: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Recipe, @valid_attrs)
  end

  test "updates and renders chosen resource when data is valid and ingredients are attached", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    ingredient = Repo.insert! %Alastair.Ingredient{
      name: "Cream",
      description: "Milkproduct",
      default_measurement_id: ml.id
    }
    recipe = Repo.insert! %Recipe{
      description: "some content", 
      instructions: "some content", 
      name: "some content", 
      person_count: 42,
      created_by: @userid
    }

    Repo.insert! %Alastair.RecipeIngredient{
      recipe: recipe,
      ingredient: ingredient,
      quantity: 50.0
    }    

    conn = put conn, recipe_path(conn, :update, recipe), recipe: Map.put(@valid_attrs, :recipes_ingredients, [%{ingredient_id: ingredient.id, quantity: 100.0}])
    assert json_response(conn, 200)["data"]["id"] == recipe.id
    assert Repo.get_by(Recipe, @valid_attrs)
    assert json_response(conn, 200)["data"]["recipes_ingredients"] != []
    assert json_response(conn, 200)["data"]["recipes_ingredients"] |> Enum.any?(fn(ri) -> 
      ri |> map_inclusion(%{"ingredient_id" => ingredient.id, "quantity" => 100.0})
    end)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    recipe = Repo.insert! %Recipe{created_by: @userid}
    conn = put conn, recipe_path(conn, :update, recipe), recipe: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not unpublish a published resource", %{conn: conn} do
    attrs = @valid_attrs
    |> Map.put(:published, true)

    conn = post conn, recipe_path(conn, :create), recipe: attrs
    assert json_response(conn, 201)["data"]["id"]

    recipe = json_response(conn, 201)["data"]["id"]
    conn = put conn, recipe_path(conn, :update, recipe), recipe: Map.put(@valid_attrs, :published, false)
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "creates a new version when attempting to update a published recipe", %{conn: conn} do
    attrs = @valid_attrs
    |> Map.put(:name, "something")
    |> Map.put(:published, true)

    conn = post conn, recipe_path(conn, :create), recipe: attrs
    assert json_response(conn, 201)["data"]["id"]

    recipe = Repo.get!(Recipe, json_response(conn, 201)["data"]["id"])

    attrs = @valid_attrs
    |> Map.put(:name, "something-completely-different")
    |> Map.delete(:published)

    conn = put conn, recipe_path(conn, :update, recipe), recipe: attrs
    assert json_response(conn, 200)["data"]["id"] != recipe.id
    assert json_response(conn, 200)["data"]["version"] == recipe.version + 1
    assert json_response(conn, 200)["data"]["name"] == "something-completely-different"

    # Old recipe should be unpublished
    assert recipe.published
    recipe = Repo.get!(Recipe, recipe.id)
    refute recipe.published
  end

  test "deletes chosen resource when unpublished", %{conn: conn} do
    recipe = Repo.insert! %Recipe{created_by: @userid}
    conn = delete conn, recipe_path(conn, :delete, recipe)
    assert response(conn, 204)
    refute Repo.get(Recipe, recipe.id)
  end

  test "does not delete resource by another user", %{conn: conn} do
    recipe = Repo.insert! %Recipe{created_by: "another-invalid-id"}
    conn = delete conn, recipe_path(conn, :delete, recipe)
    assert response(conn, 405)
  end

  test "does not delete chosen resource when published", %{conn: conn} do
    recipe = Repo.insert! %Recipe{published: true}
    conn = delete conn, recipe_path(conn, :delete, recipe)
    assert response(conn, 405)
    assert Repo.get(Recipe, recipe.id)
  end
end
