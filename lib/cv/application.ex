defmodule Cv.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Cv.Repo,
      # Start the Telemetry supervisor
      CvWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Cv.PubSub},
      # Start the Endpoint (http/https)
      CvWeb.Endpoint,
      # Start a worker by calling: Cv.Worker.start_link(arg)
      # {Cv.Worker, arg}
      # image service thing
      #{Cv.ImageServer, name: Cv.ImageServer}
      #Cv.ImageServer,
      Cv.ServerMap,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cv.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CvWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
