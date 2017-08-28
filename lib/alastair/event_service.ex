defmodule Alastair.EventService do
  def get_event(event_id) do
    event_service = Application.get_env(:alastair, Alastair.Endpoint)[:event_service]
    apply(Alastair.EventService, event_service, [event_id])
  end

  # For tests and until oms-events is stable again
  def static_event(event_id) do
    %{id: event_id,
      name: event_id,
      starts: Ecto.DateTime.cast!("2015-08-05T08:40:51.620Z"),
      ends: Ecto.DateTime.cast!("2015-08-10T08:40:51.620Z"),
      organizers_list: [%{
        foreign_id: "1"
      }]
    }
  end
end