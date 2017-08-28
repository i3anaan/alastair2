defmodule Alastair.EventController do
  use Alastair.Web, :controller
  alias Alastair.Event

  def get_event(id) do
    db_event = case Repo.get_by(Event, id: id) do
      nil -> Repo.insert!(%Event{id: id})
      event -> event
    end
    remote_event = Alastair.EventService.get_event(id)

    db_event
    |> Map.put(:name, remote_event.name)
    |> Map.put(:starts, remote_event.starts)
    |> Map.put(:ends, remote_event.ends)
    |> Map.put(:organizers, remote_event.organizers_list)
  end

  def get_event_editors(id) do
    from(p in Alastair.EventEditor, where: p.event_id == ^id) |> Repo.all
  end

  def get_meals(id) do
    from(p in Alastair.Meal, where: p.event_id == ^id) |> Repo.all
  end

  # TODO only list own users events
  def index(conn, params) do
    events = from(p in Event)
    |> Repo.all

    events = events
    |> Enum.map(fn(event) -> 
      Task.async(fn -> # Spawn as async tasks as every event involves a GET to oms-events
        remote_event = Alastair.EventService.get_event(event.id)

        event
        |> Map.put(:name, remote_event.name)
        |> Map.put(:starts, remote_event.starts)
        |> Map.put(:ends, remote_event.ends)
        |> Map.put(:organizers, remote_event.organizers_list)
      end)
    end)
    |> Enum.map(fn(task) -> Task.await(task) end)

    render(conn, "index.json", events: events)
  end

  # It is only possible to show an event, if it does not exist in our database we create it right away
  # TODO fetch event details from oms-events
  def show(conn, %{"id" => id}) do
    event = get_event(id)
    |> Map.put(:event_editors, get_event_editors(id))
    |> Map.put(:meals, get_meals(id))
    |> Repo.preload([{:shop, [:currency]}])

    render(conn, "show.json", event: event)
  end


  def update(conn, %{"id" => id, "event" => event_params}) do
    event = get_event(id)
    changeset = Event.changeset(event, event_params)

    case Repo.update(changeset) do
      {:ok, event} ->
        from(p in Alastair.ShoppingListNote,
          where: p.event_id == ^id)
        |> Repo.delete_all

        event = Repo.preload(event, [{:shop, [:currency]}])
        |> Map.put(:meals, get_meals(id))
        |> Map.put(:event_editors, get_event_editors(id))
        
        render(conn, "show.json", event: event)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Alastair.ChangesetView, "error.json", changeset: changeset)
    end
  end
end
