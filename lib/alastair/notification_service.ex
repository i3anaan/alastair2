defmodule Alastair.NotificationService do

  use Alastair.Web, :controller # To use render

  def dispatch_notification(token, notification) do
    service = Application.get_env(:alastair, Alastair.Endpoint)[:notification_service]
    spawn fn -> apply(Alastair.NotificationService, service, [token, notification]) end
  end

  def dispatch_static(_token, _notification) do
    # aaand it's gone
    # the money is gone.
  end

  def dispatch_oms(token, notification) do
    notification = notification
    |> Map.put(:time, DateTime.to_iso8601(DateTime.utc_now()))
    |> Map.put(:service, "alastair")
    |> Poison.encode!

    case HTTPoison.post("http://oms-notification-cast:8001/cast", notification, [{"Content-Type", "application/json"}, {"X-Auth-Token", token}]) do
      {:ok, response} -> response
      {:error, error} -> error
    end
  end
end
