defmodule CvWeb.Router do
  use CvWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", CvWeb do
    pipe_through :browser

    get "/", PageController, :index

    post "/submit", PageController, :submit
    get "/submit", PageController, :submit
    get "/submitted", PageController, :submitted
    get "/get", PageController, :get
    get "/out/:id", PageController, :out
    post "/rate", PageController, :rate

    # terms and conditions
    get "/tnc", PageController, :tnc

    get "/login", AuthController, :login
    post "/auth", AuthController, :auth
  end

  defp authenticate(conn, _) do
    if !get_session(conn, :is_admin) do
      conn |> put_flash(:info, "You must be logged in") |> redirect(to: "/") |> halt()
    else
      conn
    end
  end

  scope "/admin", CvWeb do
    pipe_through [:browser, :authenticate]
    get "/", PageController, :admin_index
    resources "/methods", MethodController
    resources "/submissions", SubmissionController
    get "/submissions/img/:id", SubmissionController, :img
  end

  # Other scopes may use custom stacks.
  # scope "/api", CvWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: CvWeb.Telemetry
    end
  end
end
