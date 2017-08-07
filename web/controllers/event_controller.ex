defmodule Alastair.EventController do
  use Alastair.Web, :controller

  alias Alastair.Event

  defp create_event(id) do
    Repo.insert!(%Event{id: id})
  end

  def get_event_editors(id) do
    from(p in Alastair.EventEditor, where: p.event_id == ^id) |> Repo.all
  end

  # It is only possible to show an event, if it does not exist in our database we create it right away
  # TODO fetch event details from oms-events
  def show(conn, %{"id" => id}) do
    event = case Repo.get_by(Event, id: id) do
      nil -> create_event(id)
      event -> event
    end

    event = Map.put(event, :event_editors, get_event_editors(id))

    render(conn, "show.json", event: event)
  end

end
