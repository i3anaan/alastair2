defmodule Alastair.ShoppingItemController do
  use Alastair.Web, :controller

  alias Alastair.ShoppingItem

  def index(conn, _params) do
    shopping_items = Repo.all(ShoppingItem)
    render(conn, "index.json", shopping_items: shopping_items)
  end

  def create(conn, %{"shopping_item" => shopping_item_params, "shop_id" => shop_id}) do
    changeset = ShoppingItem.changeset(%ShoppingItem{}, shopping_item_params)

    case Repo.insert(changeset) do
      {:ok, shopping_item} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", shop_shopping_item_path(conn, :show, shop_id, shopping_item))
        |> render("show.json", shopping_item: shopping_item)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    shopping_item = Repo.get!(ShoppingItem, id)
    render(conn, "show.json", shopping_item: shopping_item)
  end

  def update(conn, %{"id" => id, "shopping_item" => shopping_item_params}) do
    shopping_item = Repo.get!(ShoppingItem, id)
    changeset = ShoppingItem.changeset(shopping_item, shopping_item_params)

    case Repo.update(changeset) do
      {:ok, shopping_item} ->
        render(conn, "show.json", shopping_item: shopping_item)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    shopping_item = Repo.get!(ShoppingItem, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(shopping_item)

    send_resp(conn, :no_content, "")
  end
end
