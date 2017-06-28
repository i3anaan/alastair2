defmodule Alastair.DatabaseControllerTest do
  use Alastair.ConnCase

  alias Alastair.Database
  @valid_attrs %{name: "some content"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, database_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    database = Repo.insert! %Database{}
    conn = get conn, database_path(conn, :show, database)
    assert json_response(conn, 200)["data"] == %{"id" => database.id,
      "name" => database.name}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, database_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, database_path(conn, :create), database: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Database, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, database_path(conn, :create), database: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    database = Repo.insert! %Database{}
    conn = put conn, database_path(conn, :update, database), database: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Database, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    database = Repo.insert! %Database{}
    conn = put conn, database_path(conn, :update, database), database: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    database = Repo.insert! %Database{}
    conn = delete conn, database_path(conn, :delete, database)
    assert response(conn, 204)
    refute Repo.get(Database, database.id)
  end
end
