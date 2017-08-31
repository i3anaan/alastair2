defmodule Alastair.ShopAdminController do
  use Alastair.Web, :controller

  alias Alastair.ShopAdmin

  def fetch_shop_role(conn, shop_id) do
    found = from(p in ShopAdmin,
      where: p.shop_id == ^shop_id and p.user_id == ^conn.assigns.user.id)
    |> Repo.all

    Plug.Conn.assign(conn, :shop_admin, found != [])
  end

  def own_user(conn, _params) do
    user = conn.assigns.user
    |> Map.put(:shop_admin, conn.assigns.user.superadmin || conn.assigns.shop_admin)

    render(conn, "user.json", user: user)
  end

  def index(conn, %{"shop_id" => shop_id}) do
    shop_admins = from(p in ShopAdmin,
      where: p.shop_id == ^shop_id)
    |> Repo.all

    render(conn, "index.json", shop_admins: shop_admins)
  end

  def create(conn, %{"shop_id" => shop_id, "shop_admin" => shop_admin_params}) do
    conn = fetch_shop_role(conn, shop_id)

    if conn.assigns.shop_admin || conn.assigns.user.superadmin do
       changeset = ShopAdmin.changeset(%ShopAdmin{}, shop_admin_params)

      case Repo.insert(changeset) do
        {:ok, shop_admin} ->
          conn
          |> put_status(:created)
          |> render("show.json", shop_admin: shop_admin)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:forbidden)
      |> render(Alastair.ErrorView, "error.json", message: "Only shop admins or alastair admins can appoint new admins")
    end
  end

  def delete(conn, %{"shop_id" => shop_id, "id" => id}) do
    conn = fetch_shop_role(conn, shop_id)

    if conn.assigns.shop_admin || conn.assigns.user.superadmin do
      shop_admin = from(p in ShopAdmin, where: p.id == ^id and p.shop_id == ^shop_id) |> Repo.one!

      # Here we use delete! (with a bang) because we expect
      # it to always work (and if it does not, it will raise).
      Repo.delete!(shop_admin)

      send_resp(conn, :no_content, "")
    else
      conn
      |> put_status(:forbidden)
      |> render(Alastair.ErrorView, "error.json", message: "Only shop admins or alastair admins can delete other admin roles")
    end
    
  end
end
