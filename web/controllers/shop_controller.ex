defmodule Alastair.ShopController do
  use Alastair.Web, :controller
  import Alastair.Helper

  alias Alastair.Shop

  def index(conn, params) do
    shops = from(p in Shop,
            preload: [:currency],
            order_by: :name)
    |> paginate(params)
    |> search(params)
    |> Repo.all

    render(conn, "index.json", shops: shops)
  end

  def create(conn, %{"shop" => shop_params}) do
    changeset = Shop.changeset(%Shop{}, shop_params)

    case Repo.insert(changeset) do
      {:ok, shop} ->
        shop = Repo.preload(shop, [:currency])

        conn
        |> put_status(:created)
        |> put_resp_header("location", shop_path(conn, :show, shop))
        |> render("show.json", shop: shop)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    shop = Repo.get!(Shop, id)
    |> Repo.preload([:currency])

    render(conn, "show.json", shop: shop)
  end

  def update(conn, %{"id" => id, "shop" => shop_params}) do
    shop = Repo.get!(Shop, id)
    |> Repo.preload([:currency])
    changeset = Shop.changeset(shop, shop_params)

    case Repo.update(changeset) do
      {:ok, shop} ->
        render(conn, "show.json", shop: shop)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    if conn.assigns.user.superadmin do
      shop = Repo.get!(Shop, id)

      from(p in Alastair.ShoppingItem, where: p.shop_id == ^id) |> Repo.delete_all

      # Here we use delete! (with a bang) because we expect
      # it to always work (and if it does not, it will raise).
      Repo.delete!(shop)

      send_resp(conn, :no_content, "")
    else
      conn
      |> put_status(:forbidden)
      |> render(Alastair.ErrorView, "error.json", message: "Only admins can delete shops")
    end
  end
end
