defmodule Alastair.AdminController do
  use Alastair.Web, :controller

  alias Alastair.Admin

  def own_user(conn, _params) do
    render(conn, "user.json", user: conn.assigns.user)
  end

  def index(conn, _params) do
    admins = Repo.all(Admin)
    render(conn, "index.json", admins: admins)
  end

  def create(conn, %{"admin" => admin_params}) do
    changeset = Admin.changeset(%Admin{}, admin_params)

    case Repo.insert(changeset) do
      {:ok, admin} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", admin_path(conn, :show, admin))
        |> render("show.json", admin: admin)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def set_active(conn, %{"id" => id, "active" => active}) do
    admin = Repo.get!(Admin, id)
    if(admin.user_id == conn.assigns.user.id) do
      changeset = Admin.changeset(admin, %{"active" => active})
      case Repo.update(changeset) do
        {:ok, admin} ->
          conn
          |> render("show.json", admin: admin)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:forbidden)
      |> render(Alastair.ErrorView, "error.json", message: "You can not set the activity status of another admin but you")
    end
  end

  def show(conn, %{"id" => id}) do
    admin = Repo.get!(Admin, id)
    render(conn, "show.json", admin: admin)
  end

  def delete(conn, %{"id" => id}) do
    admin = Repo.get!(Admin, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(admin)

    send_resp(conn, :no_content, "")
  end
end
