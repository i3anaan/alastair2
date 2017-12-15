defmodule Alastair.IngredientRequestController do
  use Alastair.Web, :controller
  import Alastair.Helper

  alias Alastair.IngredientRequest

  def index(conn, params) do
    ingredient_requests = from(p in IngredientRequest,
            preload: [:default_measurement],
            order_by: [desc: :approval_state, desc: :inserted_at])
    |> paginate(params)
    |> search(params)
    |> Repo.all

    render(conn, "index.json", ingredient_requests: ingredient_requests)
  end

  def create(conn, %{"ingredient_request" => ingredient_request_params}) do
    ingredient_request_params = ingredient_request_params
    |> Map.delete("admin_message")
    |> Map.delete("approval_state")
    |> Map.put("requested_by", conn.assigns.user.id)

    changeset = IngredientRequest.changeset(%IngredientRequest{}, ingredient_request_params)

    case Repo.insert(changeset) do
      {:ok, ingredient_request} ->

        admins = Repo.all(Alastair.Admin)
        |> Enum.map(fn(x) -> x.user_id end)

        Alastair.NotificationService.dispatch_notification(Plug.Conn.get_req_header(conn, "x-auth-token"), %Alastair.Notification{
          audience_type: "user",
          audience_params: admins,
          category: "alastair.request",
          category_name: "Ingredient requests",
          heading: "New ingredient request",
          heading_link: "app.alastair_chef.ingredient_requests",
          heading_link_params: %{id: ingredient_request.id},
          body: "A missing ingredient was requested for addition and awaits your approval"
        })

        conn
        |> put_status(:created)
        |> put_resp_header("location", ingredient_request_path(conn, :show, ingredient_request))
        |> render("show.json", ingredient_request: ingredient_request)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    ingredient_request = Repo.get!(IngredientRequest, id)
    |> Repo.preload([:default_measurement])
    render(conn, "show.json", ingredient_request: ingredient_request)
  end

  def update(conn, %{"id" => id, "ingredient_request" => ingredient_request_params}) do
    if conn.assigns.user.superadmin do
      ingredient_request = Repo.get!(IngredientRequest, id)

      ingredient_request_params = ingredient_request_params
      |> Map.take(["admin_message", "approval_state"])

      changeset = IngredientRequest.changeset(ingredient_request, ingredient_request_params)

      case Repo.update(changeset) do
        {:ok, ingredient_request} ->

          if ingredient_request.approval_state == :accepted do
            Repo.insert!(%Alastair.Ingredient{
              name: ingredient_request.name,
              description: ingredient_request.description,
              default_measurement_id: ingredient_request.default_measurement_id
            })
          end

          Alastair.NotificationService.dispatch_notification(Plug.Conn.get_req_header(conn, "x-auth-token"), %Alastair.Notification{
            audience_type: "user",
            audience_params: [ingredient_request.requested_by],
            category: "alastair.request_approval",
            category_name: "Ingredient request approval",
            heading: "Ingredient request reviewed",
            heading_link: "app.alastair_chef.ingredient_requests",
            heading_link_params: %{id: ingredient_request.id},
            body: "A admin reviewed your ingredient request and set it to " <> Kernel.inspect(ingredient_request.approval_state)
          })

          render(conn, "show.json", ingredient_request: ingredient_request)
        {:error, changeset} ->
          conn
          |> put_status(:unprocessable_entity)
          |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
      end
    else
      conn
      |> put_status(:forbidden)
      |> render(Alastair.ErrorView, "error.json", message: "Only alastair admins can approve or reject ingredient requests")
    end
  end
end
