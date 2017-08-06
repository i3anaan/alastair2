defmodule Alastair.ShopView do
  use Alastair.Web, :view

  def render("index.json", %{shops: shops}) do
    %{data: render_many(shops, Alastair.ShopView, "shop.json")}
  end

  def render("show.json", %{shop: shop}) do
    %{data: render_one(shop, Alastair.ShopView, "shop.json")}
  end

  def render("shop.json", %{shop: shop}) do
    %{id: shop.id,
      name: shop.name,
      location: shop.location,
      currency_id: shop.currency_id}
  end
end
