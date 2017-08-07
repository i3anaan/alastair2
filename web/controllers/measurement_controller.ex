defmodule Alastair.MeasurementController do
  use Alastair.Web, :controller

  alias Alastair.Measurement

  def index(conn, _params) do
    measurements = Repo.all(Measurement)
    render(conn, "index.json", measurements: measurements)
  end

end
