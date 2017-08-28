defmodule Alastair.AdminView do
  use Alastair.Web, :view

  def render("index.json", %{admins: admins}) do
    %{data: render_many(admins, Alastair.AdminView, "admin.json")}
  end

  def render("show.json", %{admin: admin}) do
    %{data: render_one(admin, Alastair.AdminView, "admin.json")}
  end

  def render("admin.json", %{admin: admin}) do
    %{id: admin.id,
      user_id: admin.user_id}
  end

  def render("user.json", %{user: user}) do
    %{data: %{id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      superadmin: user.superadmin
    }}
  end
end
