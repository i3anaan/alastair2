defmodule Alastair.MeasurementControllerTest do
  use Alastair.ConnCase

  alias Alastair.Measurement
  @valid_attrs %{display_code: "some content", name: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, measurement_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    measurement = Repo.insert! %Measurement{}
    conn = get conn, measurement_path(conn, :show, measurement)
    assert json_response(conn, 200)["data"] == %{"id" => measurement.id,
      "name" => measurement.name,
      "display_code" => measurement.display_code}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, measurement_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, measurement_path(conn, :create), measurement: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Measurement, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, measurement_path(conn, :create), measurement: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    measurement = Repo.insert! %Measurement{}
    conn = put conn, measurement_path(conn, :update, measurement), measurement: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Measurement, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    measurement = Repo.insert! %Measurement{}
    conn = put conn, measurement_path(conn, :update, measurement), measurement: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    measurement = Repo.insert! %Measurement{}
    conn = delete conn, measurement_path(conn, :delete, measurement)
    assert response(conn, 204)
    refute Repo.get(Measurement, measurement.id)
  end
end
