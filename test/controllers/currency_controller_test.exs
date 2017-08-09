defmodule Alastair.CurrencyControllerTest do
  use Alastair.ConnCase


  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, currency_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "seeds currencies correctly", %{conn: conn} do
    Alastair.Seeds.CurrencySeed.run()
    conn = get conn, currency_path(conn, :index)
    assert json_response(conn, 200)["data"] |> is_list
    assert json_response(conn, 200)["data"] |> Enum.any?(fn(x) -> x["name"] == "Euro" end)
  end

end
