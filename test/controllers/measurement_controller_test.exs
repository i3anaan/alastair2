defmodule Alastair.MeasurementControllerTest do
  use Alastair.ConnCase


  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, measurement_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "seeds measurements correctly", %{conn: conn} do
    Alastair.Seeds.MeasurementSeed.run()
    conn = get conn, measurement_path(conn, :index)
    assert json_response(conn, 200)["data"] |> is_list
    assert json_response(conn, 200)["data"] |> Enum.any?(fn(x) -> x["name"] == "Gram" end)
  end

end
