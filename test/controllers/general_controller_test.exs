defmodule Alastair.GeneralControllerTest do
  use Alastair.ConnCase

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "returns status ok", %{conn: conn} do
    conn = get conn, general_path(conn, :status)
    assert json_response(conn, 200)["success"]
  end
end
