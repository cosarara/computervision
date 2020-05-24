defmodule CvWeb.PageController do
  use CvWeb, :controller

  def index(conn, _params) do
    #IO.inspect Cv.ImageServer.ping()
    render(conn, "index.html",
      allow_use: get_session(conn, :allow),
      terms: get_session(conn, :terms))
  end

  def submitted(conn, _params) do
    srv = Cv.ImageServer.get()
    user_id = get_session(conn, :user_id)
    token = Phoenix.Token.sign(CvWeb.Endpoint, "user auth", user_id)
    render(conn, "submitted.html", methods: srv.methods, ready: srv.out,
      uid_token: token, uid: user_id)
  end

  # FIXME: not actually unique
  defp gen_id() do
    Base.url_encode64(:crypto.strong_rand_bytes(20))
  end

  def submit(conn, _all = %{"image" => imgdata, "allow_use" => allow, "terms" => "true"}) do
    IO.inspect "kabum :("
    IO.inspect imgdata

    id = gen_id()
    conn = put_session(conn, :user_id, id)
    conn = put_session(conn, :allow, allow)
    conn = put_session(conn, :terms, "true")

    Cv.ImageServer.upload(imgdata)
    Cv.ImageServer.subscribe(id)
    Cv.ImageServer.process()

    redirect(conn, to: Routes.page_path(conn, :submitted))
  end

  def submit(conn, %{"image" => _imgdata, "allow_use" => _allow, "terms" => falsey}) do
    conn
    |> put_session(:terms, falsey)
    |> put_flash(:info, "You must agree to the terms and conditions")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def submit(conn, _params) do
    conn
    |> put_flash(:info, "No image selected")
    |> redirect(to: Routes.page_path(conn, :index))
  end

  def get(conn, _params) do
    file = Cv.ImageServer.get()
    conn = put_resp_content_type(conn, file.mime)
    resp(conn, 200, file.data)
  end

  #def out(conn, %{"id" => "42"}) do
  #  CvWeb.Endpoint.broadcast("user_socket:42", "disconnect", %{})
  #  #CvWeb.Endpoint.broadcast("notification:lobby", "reload", %{})
  #  #CvWeb.Endpoint.broadcast("notification:lobby", "hrm", %{})
  #  resp(conn, 200, "")
  #end

  def out(conn, %{"id" => id}) do
    #IO.inspect Cv.ImageServer.get().out
    id = String.to_existing_atom(id)
    IO.inspect id
    {img, mime} = Cv.ImageServer.get().out[id]
    conn = put_resp_content_type(conn, mime)
    resp(conn, 200, img)
  end
end
