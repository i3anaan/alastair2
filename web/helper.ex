defmodule Alastair.Helper do
  def render_assoc_one(model, view, template, assigns \\ %{}) do
    cond do
      model == nil -> nil
      !Ecto.assoc_loaded?(model) -> nil
      true -> Phoenix.View.render_one(model, view, template, assigns)
    end
  end

  def render_assoc_many(model, view, template, assigns \\ %{}) do
    cond do
      model == nil -> nil
      !Ecto.assoc_loaded?(model) -> nil
      true -> Phoenix.View.render_many(model, view, template, assigns)
    end
  end
end
