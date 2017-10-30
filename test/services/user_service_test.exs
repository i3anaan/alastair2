defmodule Alastair.UserServiceTest do
  use Alastair.ConnCase

  alias Alastair.UserService

  setup %{conn: conn} do
    {:ok, conn: put_req_header(conn, "accept", "application/json")}
  end

  @body "{\"success\":true,\"meta\":null,\"data\":{\"id\":7,\"address_id\":1,\"personal_email\":\"guest@aegee.org\",\"first_name\":\"Guest\",\"last_name\":\"User\",\"date_of_birth\":\"1990-01-31 00:00:00\",\"gender\":\"male\",\"phone\":null,\"description\":null,\"remember_token\":\"Xpfeh6aCE5PcqHWk8uPsJLWc7hbdiTEX9axdkb3OOgFrQIzknxNMnQ81S9dK\",\"is_superadmin\":0,\"is_suspended\":null,\"suspended_reason\":null,\"seo_url\":\"guest\",\"activated_at\":\"2017-10-30 17:22:21\",\"created_at\":\"2017-10-30 17:22:21\",\"updated_at\":\"2017-10-30 17:22:21\",\"internal_email\":\"guest@aegee.org\",\"first_name_simple\":\"Guest\",\"last_name_simple\":\"User\",\"address\":{\"id\":1,\"country_id\":202,\"street\":\"Campus de Elvi\u00f1a\",\"zipcode\":\"15071\",\"city\":\"A Coruna\",\"created_at\":\"2017-10-30 17:22:17\",\"updated_at\":\"2017-10-30 17:22:17\"},\"bodies\":[],\"circles\":[]},\"message\":null}"

  test "assigns a static superadmin for testing", %{conn: conn} do
    conn = UserService.static_user conn
    assert conn.assigns.user |> map_inclusion(%{
      id: "asd123", 
      first_name: "Nico", 
      last_name: "Westerbeck", 
      superadmin: true, 
      disabled_superadmin: false})
  end

  test "assigns a static user for testing", %{conn: conn} do
    conn = put_req_header(conn, "x-auth-token", "nonadmin")
    conn = UserService.static_user conn
    assert conn.assigns.user |> map_inclusion(%{
      id: "asd123", 
      first_name: "Nico", 
      last_name: "Westerbeck", 
      superadmin: false, 
      disabled_superadmin: false})
  end

  test "parses a user from a valid response", %{conn: conn} do
    response = %{status_code: 200, body: @body}
    conn = UserService.check_error(conn, response)
    assert conn.assigns.user |> map_inclusion(%{
      id: "7",
      first_name: "Guest",
      last_name: "User",
      superadmin: false,
      disabled_superadmin: false
      })
  end

  test "rejects an invalid response", %{conn: conn} do
    response = %{status_code: 500, body: "{\"success\": false;}"}
    conn = UserService.check_error(conn, response)
    assert json_response(conn, 500)
  end

end
