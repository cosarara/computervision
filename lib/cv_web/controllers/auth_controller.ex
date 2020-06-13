defmodule CvWeb.AuthController do
  use CvWeb, :controller

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def auth(conn, %{"password" => password}) do
    target = System.get_env("CV_PASSWD")
    if target != nil and password == target do
      conn
      |> put_flash(:info, "welcome")
      |> put_session(:is_admin, true)
      |> redirect(to: "/admin/") |> halt()
    else
      conn |> put_flash(:info, "wrong") |> redirect(to: "/") |> halt()
    end
  end
end
