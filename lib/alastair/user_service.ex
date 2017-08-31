defmodule Alastair.UserService do
  use Alastair.Web, :controller # To use render

  # For tests so they can run without the core being up
  def static_user(conn) do
    tmp = Plug.Conn.get_req_header(conn, "x-auth-token")
    if tmp == [] || hd(tmp) == "admin" do
      Plug.Conn.assign(conn, :user, %{id: "asd123", first_name: "Nico", last_name: "Westerbeck", superadmin: true})
    else
      Plug.Conn.assign(conn, :user, %{id: "asd123", first_name: "Nico", last_name: "Westerbeck", superadmin: false})
    end
  end

  defp fetch_admin(user_id) do
    user = Repo.get_by(Alastair.Admin, user_id: user_id)

    user != nil
  end


  defp convert_to_string(anything) do
    case anything do
      n when is_float(n) -> to_string(n)
      n when is_integer(n) -> to_string(n)
      n when is_number(n) -> to_string(n)
      n -> n
    end
  end

  defp convert_to_boolean(anything) do
    case anything do
      n when is_bitstring(n) -> n == "1"
      n when is_number(n) -> n == 1
      n when is_boolean(n) -> n
      _ -> false
    end
  end

  # Parsing a response is a bit ugly...
  defp parse_oms_user(conn, response) do
    case Poison.decode(response.body) do
      {:ok, body} -> 
        atoms = [:id, :first_name, :last_name, :bodies, :is_superadmin] # Define which atoms to parse here
        relevant? = fn (x) -> Enum.find(atoms, fn(a) -> Atom.to_string(a) == x end) end
        user = for {key, val} <- body["data"], relevant?.(key), into: %{}, do: {String.to_existing_atom(key), convert_to_string(val)}
        user = user 
        |> Map.put(:superadmin, convert_to_boolean(user.is_superadmin) || fetch_admin(user.id)) 
        |> Map.delete(:is_superadmin)



        Plug.Conn.assign(conn, :user, user)
      _ -> 
        response |> IO.inspect
        conn
        |> Plug.Conn.put_status(:internal_server_error)
        |> render(Alastair.ErrorView, "error.json", message: "Could not parse core response for user data")
    end
  end

  # HTTPoison returns :ok even on non-2xx status code, so we have to check ourselves
  defp check_error(conn, response) do
    case response.status_code do
      200 -> parse_oms_user(conn, response)
      403 ->         
        conn
        |> Plug.Conn.put_status(:unauthorized)
        |> render(Alastair.ErrorView, "error.json", message: "Core did not authenticate token")
      _ ->
        conn
        |> Plug.Conn.put_status(:internal_server_error)
        |> render(Alastair.ErrorView, "error.json", message: "Something went wrong inside the core")
    end
  end

  def oms_user(conn) do
    tmp = Plug.Conn.get_req_header(conn, "x-auth-token")
    if tmp != [] do
       token = hd(tmp);
      case HTTPoison.post("http://omscore-nginx/api/tokens/user", "{\"token\": \"" <> token <> "\"}", [{"Content-Type", "application/json"}, {"X-Auth-Token", token}]) do
        {:ok, response} -> check_error(conn, response)
        {:error, _error} ->     
          conn
          |> Plug.Conn.put_status(:internal_server_error)
          |> render(Alastair.ErrorView, "error.json", message: "Could not contact core")
      end
    else
      conn
      |> Plug.Conn.put_status(:unauthorized)
      |> render(Alastair.ErrorView, "error.json", message: "No auth token provided")
    end
  end
end
