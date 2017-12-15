defmodule Alastair.GeneralController do
  use Alastair.Web, :controller

  defp check_db() do
    try do
        Ecto.Adapters.SQL.query(Alastair.Repo, "SELECT 1")
        :ok
    rescue
      _ -> :error
    end
  end

  def status(conn, _params) do
    if check_db() == :ok do      
      conn 
      |> put_resp_content_type("application/json") 
      |> send_resp(200, "{\"success\": true}")
    else   
      conn 
      |> put_resp_content_type("application/json") 
      |> send_resp(500, "{\"success\": false}")
    end


  end
end
