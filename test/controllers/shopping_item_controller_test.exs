defmodule Alastair.ShoppingItemControllerTest do
  use Alastair.ConnCase

  alias Alastair.ShoppingItem
  @valid_attrs %{buying_quantity: "120.5", comment: "some content", price: "120.5"}
  @invalid_attrs %{}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, shopping_item_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    shopping_item = Repo.insert! %ShoppingItem{}
    conn = get conn, shopping_item_path(conn, :show, shopping_item)
    assert json_response(conn, 200)["data"] == %{"id" => shopping_item.id,
      "comment" => shopping_item.comment,
      "buying_measurement_id" => shopping_item.buying_measurement_id,
      "buying_quantity" => shopping_item.buying_quantity,
      "mapped_ingredient_id" => shopping_item.mapped_ingredient_id,
      "price" => shopping_item.price,
      "shop_id" => shopping_item.shop_id}
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, shopping_item_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, shopping_item_path(conn, :create), shopping_item: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(ShoppingItem, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, shopping_item_path(conn, :create), shopping_item: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    shopping_item = Repo.insert! %ShoppingItem{}
    conn = put conn, shopping_item_path(conn, :update, shopping_item), shopping_item: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(ShoppingItem, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    shopping_item = Repo.insert! %ShoppingItem{}
    conn = put conn, shopping_item_path(conn, :update, shopping_item), shopping_item: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    shopping_item = Repo.insert! %ShoppingItem{}
    conn = delete conn, shopping_item_path(conn, :delete, shopping_item)
    assert response(conn, 204)
    refute Repo.get(ShoppingItem, shopping_item.id)
  end
end
