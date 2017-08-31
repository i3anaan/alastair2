defmodule Alastair.ShopAdminView do
  use Alastair.Web, :view

  def render("index.json", %{shop_admins: shop_admins}) do
    %{data: render_many(shop_admins, Alastair.ShopAdminView, "shop_admin.json")}
  end

  def render("show.json", %{shop_admin: shop_admin}) do
    %{data: render_one(shop_admin, Alastair.ShopAdminView, "shop_admin.json")}
  end

  def render("shop_admin.json", %{shop_admin: shop_admin}) do
    %{id: shop_admin.id,
      user_id: shop_admin.user_id,
      shop_id: shop_admin.shop_id}
  end

  def render("user.json", %{user: user}) do
    %{data: %{
      id: user.id,
      shop_admin: user.shop_admin,
      superadmin: user.superadmin,
      first_name: user.first_name,
      last_name: user.last_name
    }}
  end
end
