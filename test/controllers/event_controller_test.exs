defmodule Alastair.EventControllerTest do
  use Alastair.ConnCase

  alias Alastair.Event
  @test_id "DevelopYourself3"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end


  test "creates resource upon show", %{conn: conn} do
    conn = get conn, event_path(conn, :show, @test_id)
    assert json_response(conn, 200)["data"] |> map_inclusion(%{"id" => @test_id})
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Alastair.Shop{
      name: "Aldi",
      location: "Dresden",
      currency: euro
    }
    get conn, event_path(conn, :show, @test_id)
    conn = put conn, event_path(conn, :update, @test_id), event: %{shop_id: shop.id}
    assert json_response(conn, 200)["data"]["id"] == @test_id
    assert Repo.get_by(Event, %{id: @test_id})
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    get conn, event_path(conn, :show, @test_id)
    conn = put conn, event_path(conn, :update, @test_id), event: %{shop_id: -1}
    assert json_response(conn, 422)["errors"] != %{}
  end
end
