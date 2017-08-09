defmodule Alastair.ShopControllerTest do
  use Alastair.ConnCase

  alias Alastair.Shop
  @valid_attrs %{location: "some content", name: "some content"}
  @invalid_attrs %{currency_id: -1}

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, shop_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "some content",
      location: "some content",
      currency: euro
    }
    conn = get conn, shop_path(conn, :show, shop)
    assert json_response(conn, 200)["data"] |> map_inclusion(%{"id" => shop.id,
      "name" => shop.name,
      "location" => shop.location,
      "currency_id" => shop.currency_id})
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      get conn, shop_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    valid_attrs = %{
      name: "some content",
      location: "some content",
      currency_id: euro.id
    }

    conn = post conn, shop_path(conn, :create), shop: valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Shop, valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, shop_path(conn, :create), shop: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }


    conn = put conn, shop_path(conn, :update, shop), shop: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Shop, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }

    conn = put conn, shop_path(conn, :update, shop), shop: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }
    
    conn = delete conn, shop_path(conn, :delete, shop)
    assert response(conn, 204)
    refute Repo.get(Shop, shop.id)
  end
end
