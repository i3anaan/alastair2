defmodule Alastair.ShoppingListControllerTest do
  use Alastair.ConnCase

  @event "DevelopYourself3"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "generates a shopping list", %{conn: conn} do
    Alastair.EventController.get_event(@event)
    conn = get conn, event_shopping_list_path(conn, :shopping_list, @event)
    assert json_response(conn, 200)["data"] == []
  end

  test "generates a shopping list on seeded db", %{conn: conn} do
    Alastair.Seeds.ExampleSeed.run()
    conn = get conn, event_shopping_list_path(conn, :shopping_list, @event)
    assert json_response(conn, 200)["data"] |> is_list
    refute json_response(conn, 200)["data"] |> Enum.empty?
  end
end
