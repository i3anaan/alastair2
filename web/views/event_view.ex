defmodule Alastair.EventView do
  use Alastair.Web, :view

  def render("index.json", %{events: events}) do
    %{data: render_many(events, Alastair.EventView, "event.json")}
  end

  def render("show.json", %{event: event}) do
    %{data: render_one(event, Alastair.EventView, "event.json")}
  end

  def render("event.json", %{event: event}) do
    %{id: event.id,
      oms_id: event.oms_id}
  end
end
