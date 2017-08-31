defmodule Alastair.ShoppingItemController do
  use Alastair.Web, :controller
  import Alastair.Helper

  alias Alastair.ShoppingItem

  def index(conn, params) do
    shop_id = params["shop_id"];
    shopping_items = from(p in ShoppingItem,
      where: p.shop_id == ^shop_id,
      preload: [{:mapped_ingredient, [:default_measurement]}],
      order_by: :name)
    |> paginate(params)
    |> search(params)
    |> Repo.all
    render(conn, "index.json", shopping_items: shopping_items)
  end

  def create(conn, %{"shopping_item" => shopping_item_params, "shop_id" => shop_id}) do
    conn = Alastair.ShopAdminController.fetch_shop_role(conn, shop_id)

    if conn.assigns.shop_admin do
      shopping_item_params = Map.put(shopping_item_params, "shop_id", shop_id)
      changeset = ShoppingItem.changeset(%ShoppingItem{}, shopping_item_params)

      case Repo.insert(changeset) do
        {:ok, shopping_item} ->
          shopping_item = Repo.preload(shopping_item, [:mapped_ingredient])

          conn
          |> put_status(:created)
          |> put_resp_header("location", shop_shopping_item_path(conn, :show, shop_id, shopping_item))
          |> render("show.json", shopping_item: shopping_item)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:forbidden)
      |> render(Alastair.ErrorView, "error.json", message: "Only shop-admins can create shopping items")
    end
  end

  def show(conn, %{"id" => id}) do
    shopping_item = Repo.get!(ShoppingItem, id)
    |> Repo.preload([:mapped_ingredient])

    render(conn, "show.json", shopping_item: shopping_item)
  end

  def update(conn, %{"id" => id, "shopping_item" => shopping_item_params, "shop_id" => shop_id}) do
    conn = Alastair.ShopAdminController.fetch_shop_role(conn, shop_id)

    if conn.assigns.shop_admin do
      shopping_item = from(p in ShoppingItem, where: p.id == ^id and p.shop_id == ^shop_id) |> Repo.one!
      changeset = ShoppingItem.changeset(shopping_item, Map.put(shopping_item_params, "shop_id", shop_id))

      case Repo.update(changeset) do
        {:ok, shopping_item} ->
          shopping_item = Repo.preload(shopping_item, [:mapped_ingredient])

          render(conn, "show.json", shopping_item: shopping_item)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:forbidden)
      |> render(Alastair.ErrorView, "error.json", message: "Only shop-admins can edit shopping items")
    end
  end

  def delete(conn, %{"id" => id, "shop_id" => shop_id}) do
    conn = Alastair.ShopAdminController.fetch_shop_role(conn, shop_id)

    if conn.assigns.shop_admin do
      shopping_item = from(p in ShoppingItem, where: p.id == ^id and p.shop_id == ^shop_id) |> Repo.one!

      # Here we use delete! (with a bang) because we expect
      # it to always work (and if it does not, it will raise).
      Repo.delete!(shopping_item)

      send_resp(conn, :no_content, "")
    else
      conn
      |> put_status(:forbidden)
      |> render(Alastair.ErrorView, "error.json", message: "Only shop-admins can delete shopping items")
    end
  end
end
