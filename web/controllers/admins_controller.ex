defmodule Alastair.AdminsController do
  use Alastair.Web, :controller
  

  def own_user(conn, _params) do
    render(conn, "user.json", user: conn.assigns.user)
  end
end
