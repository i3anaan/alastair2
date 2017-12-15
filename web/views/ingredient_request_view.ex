defmodule Alastair.IngredientRequestView do
  use Alastair.Web, :view
  import Alastair.Helper

  def render("index.json", %{ingredient_requests: ingredient_requests}) do
    %{data: render_many(ingredient_requests, Alastair.IngredientRequestView, "ingredient_request.json")}
  end

  def render("show.json", %{ingredient_request: ingredient_request}) do
    %{data: render_one(ingredient_request, Alastair.IngredientRequestView, "ingredient_request.json")}
  end

  def render("ingredient_request.json", %{ingredient_request: ingredient_request}) do
    %{id: ingredient_request.id,
      name: ingredient_request.name,
      description: ingredient_request.description,
      default_measurement_id: ingredient_request.default_measurement_id,
      default_measurement: render_assoc_one(ingredient_request.default_measurement, Alastair.MeasurementView, "measurement.json"),
      requested_by: ingredient_request.requested_by,
      admin_message: ingredient_request.admin_message,
      request_message: ingredient_request.request_message,
      approval_state: ingredient_request.approval_state,
      inserted_at: ingredient_request.inserted_at
    }
  end
end
