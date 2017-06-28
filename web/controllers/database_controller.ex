defmodule Alastair.DatabaseController do
  use Alastair.Web, :controller

  alias Alastair.Database

  def index(conn, _params) do
    databases = Repo.all(Database)
    render(conn, "index.json", databases: databases)
  end

  def create(conn, %{"database" => database_params}) do
    changeset = Database.changeset(%Database{}, database_params)

    case Repo.insert(changeset) do
      {:ok, database} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", database_path(conn, :show, database))
        |> render("show.json", database: database)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    database = Repo.get!(Database, id)
    render(conn, "show.json", database: database)
  end

  def update(conn, %{"id" => id, "database" => database_params}) do
    database = Repo.get!(Database, id)
    changeset = Database.changeset(database, database_params)

    case Repo.update(changeset) do
      {:ok, database} ->
        render(conn, "show.json", database: database)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    database = Repo.get!(Database, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(database)

    send_resp(conn, :no_content, "")
  end
end
