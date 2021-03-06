defmodule CvWeb.PageController do
  use CvWeb, :controller

  alias Cv.Submissions
  alias Cv.Submissions.Submission

  def index(conn, _params) do
    #IO.inspect Cv.ImageServer.ping()
    render(conn, "index.html",
      allow_use: get_session(conn, :allow),
      terms: get_session(conn, :terms))
  end

  def admin_index(conn, _params) do
    render(conn, "admin.html")
  end

  def submitted(conn, _params) do
    #pid = get_session(conn, :imgsrv)
    user_id = get_session(conn, :user_id)
    pid = Cv.ServerMap.get(user_id)
    state = Cv.ImageServer.get(pid)
    token = Phoenix.Token.sign(CvWeb.Endpoint, "user auth", user_id)
    #IO.inspect "thikning hard"
    #IO.inspect state.status
    #IO.inspect Cv.ServerMap.get(user_id)
    render(conn, "submitted.html", methods: state.methods, status: state.status,
      ratings: state.ratings, uid_token: token, uid: user_id)
  end

  # FIXME: not actually unique
  defp gen_id() do
    Base.url_encode64(:crypto.strong_rand_bytes(20))
  end

  def submit(conn, _all = %{"image" => imgdata, "allow_use" => allow, "terms" => "true"}) do
    IO.inspect "submit"
    #IO.inspect imgdata

    user_id = get_session(conn, :user_id)
    pid = Cv.ServerMap.get(user_id)
    pid = if !pid or not Process.alive?(pid) do
      {:ok, pid} = Cv.ImageServer.start_link([])
      pid
    else
      pid
    end

    id = gen_id()
    Cv.ServerMap.set(id, pid)
    conn = conn
           |> put_session(:user_id, id)
           |> put_session(:allow, allow)
           |> put_session(:terms, "true")
           #|> put_session(:imgsrv, pid)

    {image, mime} = Cv.ImageServer.upload(pid, imgdata)
    #IO.inspect "hrmmmm"
    #IO.inspect {image, mime}
    {:ok, submission} = Submissions.create_submission(
      %{"image" => (if allow == "true", do: image, else: nil), "mime" => mime})
    #IO.inspect "kabum"
    #IO.inspect submission
    #IO.inspect submission.id
    Cv.ImageServer.set_submission(pid, submission.id)
    Cv.ImageServer.subscribe(pid, id)
    Cv.ImageServer.process(pid)

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
    user_id = get_session(conn, :user_id)
    pid = Cv.ServerMap.get(user_id)
    file = Cv.ImageServer.get(pid)
    conn = put_resp_content_type(conn, file.mime)
    resp(conn, 200, file.data)
  end

  def out(conn, %{"id" => id}) do
    #IO.inspect Cv.ImageServer.get(pid).out
    id = String.to_existing_atom(id)
    IO.inspect id
    user_id = get_session(conn, :user_id)
    pid = Cv.ServerMap.get(user_id)
    {img, mime} = Cv.ImageServer.get(pid).out[id]
    conn = put_resp_content_type(conn, mime)
    resp(conn, 200, img)
  end

  def rate(conn, %{"method" => method, "rating" => rating}) do
    user_id = get_session(conn, :user_id)
    pid = Cv.ServerMap.get(user_id)
    method = String.to_existing_atom(method)
    Cv.ImageServer.rate(pid, method, rating)
    IO.inspect Cv.ImageServer.get(pid).ratings
    conn
    |> resp(200, "")
  end

  def tnc(conn, _params) do
    render(conn, "tnc.html")
  end
end
