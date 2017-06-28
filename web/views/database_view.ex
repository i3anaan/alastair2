defmodule Alastair.DatabaseView do
  use Alastair.Web, :view

  def render("index.json", %{databases: databases}) do
    %{data: render_many(databases, Alastair.DatabaseView, "database.json")}
  end

  def render("show.json", %{database: database}) do
    %{data: render_one(database, Alastair.DatabaseView, "database.json")}
  end

  def render("database.json", %{database: database}) do
    %{id: database.id,
      name: database.name}
  end
end
