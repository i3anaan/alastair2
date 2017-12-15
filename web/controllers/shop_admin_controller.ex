defmodule Alastair.ShopAdminController do
  use Alastair.Web, :controller

  alias Alastair.ShopAdmin

  def fetch_shop_role(conn, shop_id) do
    found = from(p in ShopAdmin,
      where: p.shop_id == ^shop_id and p.user_id == ^conn.assigns.user.id)
    |> Repo.all

    Plug.Conn.assign(conn, :shop_admin, found != [])
  end

  def own_user(conn, %{"shop_id" => shop_id}) do
    conn = fetch_shop_role(conn, shop_id)

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
       changeset = ShopAdmin.changeset(%ShopAdmin{}, Map.put(shop_admin_params, "shop_id", shop_id))

      case Repo.insert(changeset) do
        {:ok, shop_admin} ->

          Alastair.NotificationService.dispatch_notification(Plug.Conn.get_req_header(conn, "x-auth-token"), %Alastair.Notification{
            audience_type: "user",
            audience_params: [shop_admin.user_id],
            category: "alastair.shopadmin",
            category_name: "Alastair shop-admin status",
            heading: "You are shop-admin now",
            heading_link: "app.alastair_shopping.admins",
            heading_link_params: %{id: shop_id},
            body: "You have been appointed shop admin by " <> conn.assigns.user.first_name <> " " <> conn.assigns.user.last_name
          })

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

      Alastair.NotificationService.dispatch_notification(Plug.Conn.get_req_header(conn, "x-auth-token"), %Alastair.Notification{
        audience_type: "user",
        audience_params: [shop_admin.user_id],
        category: "alastair.shopadmin",
        category_name: "Alastair shop-admin status",
        heading: "You are not shop-admin anymore",
        heading_link: "app.alastair_shopping.admins",
        heading_link_params: %{id: shop_id},
        body: "You have been dismissed as shop admin by " <> conn.assigns.user.first_name <> " " <> conn.assigns.user.last_name
      })

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
