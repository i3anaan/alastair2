defmodule Alastair.PageController do
  use Alastair.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
