defmodule Alastair.MeasurementView do
  use Alastair.Web, :view

  def render("index.json", %{measurements: measurements}) do
    %{data: render_many(measurements, Alastair.MeasurementView, "measurement.json")}
  end

  def render("show.json", %{measurement: measurement}) do
    %{data: render_one(measurement, Alastair.MeasurementView, "measurement.json")}
  end

  def render("measurement.json", %{measurement: measurement}) do
    %{id: measurement.id,
      name: measurement.name,
      plural_name: measurement.plural_name,
      display_code: measurement.display_code}
  end
end
