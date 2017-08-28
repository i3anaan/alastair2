defmodule Alastair.EventView do
  use Alastair.Web, :view
  import Alastair.Helper

  def render("index.json", %{events: events}) do
    %{data: render_many(events, Alastair.EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, Alastair.EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    %{id: event.id,
      name: event.name,
      starts: event.starts,
      ends: event.ends,
      shop_id: event.shop_id,
      shop: render_assoc_one(event.shop, Alastair.ShopView, "shop.json"),
      meals: render_assoc_many(event.meals, Alastair.MealView, "meal.json")
    }
  end
end
