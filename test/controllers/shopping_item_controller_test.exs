defmodule Alastair.ShoppingItemControllerTest do
  use Alastair.ConnCase, async: false
  require Logger

  alias Alastair.ShoppingItem

  @valid_attrs %{buying_quantity: "120.5", comment: "some content", price: "120.5"}
  @invalid_attrs %{}
  @user_id "asd123"

  setup %{conn: conn} do
    conn = conn
    |> put_req_header("accept", "application/json") 
    |> put_req_header("x-auth-token", "nonadmin")

    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Alastair.Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }
    conn = get conn, shop_shopping_item_path(conn, :index, shop)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    ingredient = Repo.insert! %Alastair.Ingredient{
      name: "Cream",
      description: "Milkproduct",
      default_measurement_id: ml.id
    }

    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Alastair.Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }

    shopping_item = Alastair.Repo.insert! %Alastair.ShoppingItem{
      name: "Supercream",
      buying_quantity: 2500.0,
      flexible_amount: false,
      price: 1.39,
      mapped_ingredient: ingredient,
      shop: shop
    }

    conn = get conn, shop_shopping_item_path(conn, :show, shop, shopping_item)
    assert json_response(conn, 200)["data"] |> map_inclusion(%{"id" => shopping_item.id,
      "comment" => shopping_item.comment,
      "buying_quantity" => shopping_item.buying_quantity,
      "mapped_ingredient_id" => shopping_item.mapped_ingredient_id,
      "price" => shopping_item.price,
      "flexible_amount" => shopping_item.flexible_amount})
  end

  test "renders page not found when id is nonexistent", %{conn: conn} do
    assert_error_sent 404, fn ->
      %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
      shop = Repo.insert! %Alastair.Shop{
        name: "blablabla",
        location: "blablabla",
        currency: euro
      }

      get conn, shop_shopping_item_path(conn, :show, shop, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run
    ingredient = Repo.insert! %Alastair.Ingredient{
      name: "Cream",
      description: "Milkproduct",
      default_measurement_id: ml.id
    }

    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Alastair.Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }
    Repo.insert! %Alastair.ShopAdmin{
      user_id: @user_id,
      shop: shop
    }


    valid_attrs = %{
      name: "Supercream",
      buying_quantity: 2500.0,
      flexible_amount: false,
      price: 1.39,
      mapped_ingredient_id: ingredient.id,
      shop_id: shop.id
    }

    conn = post conn, shop_shopping_item_path(conn, :create, shop), shopping_item: valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(ShoppingItem, valid_attrs)
  end

  test "does not create chosen resource when requested by a non-admin", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run
    ingredient = Repo.insert! %Alastair.Ingredient{
      name: "Cream",
      description: "Milkproduct",
      default_measurement_id: ml.id
    }

    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Alastair.Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }


    valid_attrs = %{
      name: "Supercream",
      buying_quantity: 2500.0,
      flexible_amount: false,
      price: 1.39,
      mapped_ingredient_id: ingredient.id,
      shop_id: shop.id
    }

    conn = post conn, shop_shopping_item_path(conn, :create, shop), shopping_item: valid_attrs
    assert json_response(conn, 403)
    refute Repo.get_by(ShoppingItem, valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Alastair.Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }
    Repo.insert! %Alastair.ShopAdmin{
      user_id: @user_id,
      shop: shop
    }

    conn = post conn, shop_shopping_item_path(conn, :create, shop), shopping_item: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    ingredient = Repo.insert! %Alastair.Ingredient{
      name: "Cream",
      description: "Milkproduct",
      default_measurement_id: ml.id
    }

    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Alastair.Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }
    Repo.insert! %Alastair.ShopAdmin{
      user_id: @user_id,
      shop: shop
    }

    shopping_item = Alastair.Repo.insert!(%Alastair.ShoppingItem{
      name: "Supercream",
      buying_quantity: 2500.0,
      flexible_amount: false,
      price: 1.39,
      mapped_ingredient: ingredient,
      shop: shop
    })    

    conn = put conn, shop_shopping_item_path(conn, :update, shop, shopping_item), shopping_item: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(ShoppingItem, @valid_attrs)
  end

  test "does not update chosen resource when requested by a non-shopadmin", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    ingredient = Repo.insert! %Alastair.Ingredient{
      name: "Cream",
      description: "Milkproduct",
      default_measurement_id: ml.id
    }

    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Alastair.Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }

    shopping_item = Alastair.Repo.insert!(%Alastair.ShoppingItem{
      name: "Supercream",
      buying_quantity: 2500.0,
      flexible_amount: false,
      price: 1.39,
      mapped_ingredient: ingredient,
      shop: shop
    })    

    conn = put conn, shop_shopping_item_path(conn, :update, shop, shopping_item), shopping_item: @valid_attrs
    assert json_response(conn, 403)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    ingredient = Repo.insert! %Alastair.Ingredient{
      name: "Cream",
      description: "Milkproduct",
      default_measurement_id: ml.id
    }

    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Alastair.Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }
    Repo.insert! %Alastair.ShopAdmin{
      user_id: @user_id,
      shop: shop
    }

    shopping_item = Alastair.Repo.insert!(%Alastair.ShoppingItem{
      name: "Supercream",
      buying_quantity: 2500.0,
      flexible_amount: false,
      price: 1.39,
      mapped_ingredient: ingredient,
      shop: shop
    })

    conn = put conn, shop_shopping_item_path(conn, :update, shop, shopping_item), shopping_item: %{price: -1.2}
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    ingredient = Repo.insert! %Alastair.Ingredient{
      name: "Cream",
      description: "Milkproduct",
      default_measurement_id: ml.id
    }

    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Alastair.Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }
    Repo.insert! %Alastair.ShopAdmin{
      user_id: @user_id,
      shop: shop
    }

    shopping_item = Alastair.Repo.insert!(%Alastair.ShoppingItem{
      name: "Supercream",
      buying_quantity: 2500.0,
      flexible_amount: false,
      price: 1.39,
      mapped_ingredient: ingredient,
      shop: shop
    })

    conn = delete conn, shop_shopping_item_path(conn, :delete, shop, shopping_item)
    assert response(conn, 204)
    refute Repo.get(ShoppingItem, shopping_item.id)
  end

  test "does not delete chosen resource when requested by a non-shopadmin", %{conn: conn} do
    %{:ml => ml} = Alastair.Seeds.MeasurementSeed.run()
    ingredient = Repo.insert! %Alastair.Ingredient{
      name: "Cream",
      description: "Milkproduct",
      default_measurement_id: ml.id
    }

    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Alastair.Shop{
      name: "blablabla",
      location: "blablabla",
      currency: euro
    }


    shopping_item = Alastair.Repo.insert!(%Alastair.ShoppingItem{
      name: "Supercream",
      buying_quantity: 2500.0,
      flexible_amount: false,
      price: 1.39,
      mapped_ingredient: ingredient,
      shop: shop
    })

    conn = delete conn, shop_shopping_item_path(conn, :delete, shop, shopping_item)
    assert response(conn, 403)
    assert Repo.get(ShoppingItem, shopping_item.id)
  end
end
