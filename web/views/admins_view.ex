defmodule Alastair.AdminsView do
  use Alastair.Web, :view

  def render("user.json", %{user: user}) do
    %{id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      superadmin: user.superadmin
    }
  end
end
