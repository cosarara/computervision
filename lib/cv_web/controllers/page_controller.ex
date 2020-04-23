defmodule CvWeb.PageController do
  use CvWeb, :controller

  def index(conn, _params) do
    #IO.inspect Cv.ImageServer.ping()
    render(conn, "index.html")
  end

  def submitted(conn, _params) do
    render(conn, "submitted.html")
  end

  def submit(conn, %{"image" => imgdata}) do
    IO.inspect imgdata
    IO.inspect get_session(conn)
    Cv.ImageServer.upload(imgdata)
    Cv.ImageServer.process()
    redirect(conn, to: Routes.page_path(conn, :submitted))
  end

  def submit(conn, _params) do
    redirect(conn, to: Routes.page_path(conn, :submitted))
  end

  def get(conn, _params) do
    file = Cv.ImageServer.get()
    #IO.inspect file.data
    conn = put_resp_content_type(conn, file.mime)
    resp(conn, 200, file.data)
  end

  def out(conn, _params) do
    file = Cv.ImageServer.get()
    #IO.inspect file.data
    conn = put_resp_content_type(conn, file.mime)
    resp(conn, 200, file.out)
  end
end
