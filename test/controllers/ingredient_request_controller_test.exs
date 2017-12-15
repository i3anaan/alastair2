defmodule Alastair.IngredientRequestControllerTest do
  use Alastair.ConnCase

  alias Alastair.IngredientRequest
  @valid_attrs %{description: "some content", name: "some content", request_message: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, ingredient_request_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    ingredient_request = Repo.insert! %IngredientRequest{}
    conn = get conn, ingredient_request_path(conn, :show, ingredient_request)
    assert json_response(conn, 200)["data"] |> map_inclusion(%{"id" => ingredient_request.id,
      "name" => ingredient_request.name,
      "description" => ingredient_request.description,
      "default_measurement_id" => ingredient_request.default_measurement_id,
      "requested_by" => ingredient_request.requested_by,
      "admin_message" => ingredient_request.admin_message,
      "request_message" => ingredient_request.request_message})
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, ingredient_request_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    valid_attrs = Map.put(@valid_attrs, :default_measurement_id, ml.id)

    conn = post conn, ingredient_request_path(conn, :create), ingredient_request: valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(IngredientRequest, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, ingredient_request_path(conn, :create), ingredient_request: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "approves request and generates an ingredient", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    valid_attrs = Map.put(@valid_attrs, :default_measurement_id, ml.id)

    conn = post conn, ingredient_request_path(conn, :create), ingredient_request: valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    ingredient_request = Repo.get_by(IngredientRequest, @valid_attrs)
    assert ingredient_request

    conn = put conn, ingredient_request_path(conn, :update, ingredient_request), ingredient_request: %{admin_message: "Hello", approval_state: "accepted"}
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Alastair.Ingredient, Map.take(valid_attrs, [:name, :description, :default_measurement_id]))
  end

  test "rejects request and doesn't generate an ingredient", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    valid_attrs = Map.put(@valid_attrs, :default_measurement_id, ml.id)

    conn = post conn, ingredient_request_path(conn, :create), ingredient_request: valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    ingredient_request = Repo.get_by(IngredientRequest, @valid_attrs)
    assert ingredient_request

    conn = put conn, ingredient_request_path(conn, :update, ingredient_request), ingredient_request: %{admin_message: "Hello", approval_state: "rejected"}
    assert json_response(conn, 200)["data"]["id"]
    refute Repo.get_by(Alastair.Ingredient, Map.take(valid_attrs, [:name, :description, :default_measurement_id]))
  end

  test "does not reapprove a request", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    valid_attrs = Map.put(@valid_attrs, :default_measurement_id, ml.id)

    conn = post conn, ingredient_request_path(conn, :create), ingredient_request: valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    ingredient_request = Repo.get_by(IngredientRequest, @valid_attrs)
    assert ingredient_request

    conn = put conn, ingredient_request_path(conn, :update, ingredient_request), ingredient_request: %{admin_message: "Hello", approval_state: "rejected"}
    assert json_response(conn, 200)["data"]["id"]
    refute Repo.get_by(Alastair.Ingredient, Map.take(valid_attrs, [:name, :description, :default_measurement_id]))

    conn = put conn, ingredient_request_path(conn, :update, ingredient_request), ingredient_request: %{admin_message: "Hello", approval_state: "accepted"}
    assert json_response(conn, 422)
    refute Repo.get_by(Alastair.Ingredient, Map.take(valid_attrs, [:name, :description, :default_measurement_id]))
  end

  test "does not approve request when requested by a non-admin", %{conn: conn} do
    conn_copy = conn
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    valid_attrs = Map.put(@valid_attrs, :default_measurement_id, ml.id)

    conn = post conn, ingredient_request_path(conn, :create), ingredient_request: valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    ingredient_request = Repo.get_by(IngredientRequest, @valid_attrs)
    assert ingredient_request

    conn = put_req_header(conn_copy, "x-auth-token", "nonadmin")
    conn = put conn, ingredient_request_path(conn, :update, ingredient_request), ingredient_request: %{admin_message: "Hello", approval_state: "accepted"}
    assert json_response(conn, 403)
    refute Repo.get_by(Alastair.Ingredient, Map.take(valid_attrs, [:name, :description, :default_measurement_id]))
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    ingredient_request = Repo.insert! %IngredientRequest{}
    conn = put conn, ingredient_request_path(conn, :update, ingredient_request), ingredient_request: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

end
