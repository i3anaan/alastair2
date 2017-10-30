defmodule Alastair.ShopAdminControllerTest do
  use Alastair.ConnCase

  alias Alastair.Shop
  alias Alastair.ShopAdmin
  @invalid_attrs %{}
  @user_id "asd123"

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  test "lists no entries on empty index", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "some content",
      location: "some content",
      currency: euro
    }
    
    conn = get conn, shop_shop_admin_path(conn, :index, shop)
    assert json_response(conn, 200)["data"] == []
  end


  test "lists all entries on index", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "some content",
      location: "some content",
      currency: euro
    }
    Repo.insert! %ShopAdmin{
      user_id: @user_id,
      shop: shop
    }
    
    conn = get conn, shop_shop_admin_path(conn, :index, shop)
    assert json_response(conn, 200)["data"] != []
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "some content",
      location: "some content",
      currency: euro
    }
    Repo.insert! %ShopAdmin{
      user_id: @user_id,
      shop: shop
    }

    valid_attrs = %{
      user_id: "1",
      shop_id: shop.id
    }

    conn = post conn, shop_shop_admin_path(conn, :create, shop), shop_admin: valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(ShopAdmin, valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "some content",
      location: "some content",
      currency: euro
    }
    Repo.insert! %ShopAdmin{
      user_id: @user_id,
      shop: shop
    }

    conn = post conn, shop_shop_admin_path(conn, :create, shop), shop_admin: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "does not allow duplicate entries", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "some content",
      location: "some content",
      currency: euro
    }
    Repo.insert! %ShopAdmin{
      user_id: @user_id,
      shop: shop
    }

    valid_attrs = %{
      user_id: "1",
      shop_id: shop.id
    }

    conn = post conn, shop_shop_admin_path(conn, :create, shop), shop_admin: valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(ShopAdmin, valid_attrs)
    conn = post conn, shop_shop_admin_path(conn, :create, shop), shop_admin: valid_attrs
    assert json_response(conn, 422)
  end

  test "does not create resource when requested by a non-shop-admin", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "some content",
      location: "some content",
      currency: euro
    }

    valid_attrs = %{
      user_id: "1",
      shop_id: shop.id
    }
    conn = put_req_header(conn, "x-auth-token", "nonadmin")
    conn = post conn, shop_shop_admin_path(conn, :create, shop), shop_admin: valid_attrs
    assert json_response(conn, 403)
  end

  test "deletes chosen resource", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "some content",
      location: "some content",
      currency: euro
    }
    Repo.insert! %ShopAdmin{
      user_id: @user_id,
      shop: shop
    }

    shop_admin = Repo.insert! %ShopAdmin{
      user_id: "1",
      shop_id: shop.id
    }
    conn = delete conn, shop_shop_admin_path(conn, :delete, shop, shop_admin)
    assert response(conn, 204)
    refute Repo.get(ShopAdmin, shop_admin.id)
  end

  test "does not delete chosen resource when requested by a non-shop-admin", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "some content",
      location: "some content",
      currency: euro
    }


    shop_admin = Repo.insert! %ShopAdmin{
      user_id: "1",
      shop_id: shop.id
    }

    conn = put_req_header(conn, "x-auth-token", "nonadmin")
    conn = delete conn, shop_shop_admin_path(conn, :delete, shop, shop_admin)
    assert response(conn, 403)
  end

  test "returns own user-role for shopadmins", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "some content",
      location: "some content",
      currency: euro
    }


    Repo.insert! %ShopAdmin{
      user_id: "asd123",
      shop_id: shop.id
    }

    conn = put_req_header(conn, "x-auth-token", "nonadmin")
    conn = get conn, shop_shop_admin_path(conn, :own_user, shop)
    assert json_response(conn, 200)["data"]["shop_admin"]
  end

  test "returns own user-role for non-shopadmins", %{conn: conn} do
    %{:euro => euro} = Alastair.Seeds.CurrencySeed.run
    shop = Repo.insert! %Shop{
      name: "some content",
      location: "some content",
      currency: euro
    }

    conn = put_req_header(conn, "x-auth-token", "nonadmin")
    conn = get conn, shop_shop_admin_path(conn, :own_user, shop)
    refute json_response(conn, 200)["data"]["shop_admin"]
  end

end
