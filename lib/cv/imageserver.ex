defmodule Cv.ImageServer do
  use GenServer

  # client

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def upload(input) do
    GenServer.call(__MODULE__, {:upload, input})
  end

  def get() do
    GenServer.call(__MODULE__, :get)
  end

  def ping() do
    GenServer.call(__MODULE__, :ping)
  end

  def process() do
    GenServer.cast(__MODULE__, :process)
  end

  def subscribe(id) do
    GenServer.cast(__MODULE__, {:subscribe, id})
  end

  # server

  @impl true
  def init(state) do
    {:ok, state}
  end

  @impl true
  def handle_call({:upload, upload}, _from, _state) do
    #data = 0
    data = File.read!(upload.path)
    #case File.read upload.path do
    #  {:ok, body} ->
    state = %{data: data, mime: upload.content_type, name: upload.filename,
      subscribed: nil,
      out: %{},
      methods: [
        {:EAST, "http://127.0.0.1:4010/process"},
        {:AdvancedEAST, "http://127.0.0.1:4011/process"}
      ]}
    #GenServer.cast(__MODULE__, :process)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:get, _from, state) do
    {:reply, state, state}
  end

  @impl true
  def handle_call(:ping, _from, state) do
    {:reply, :pong, state}
  end

  @impl true
  def handle_call({:process_end, method, response}, _from, state) do
    %HTTPoison.Response{status_code: 200, body: resp_body} = response
    %{"image" => image64, "mime" => mime} = Jason.decode!(resp_body)
    image = Base.decode64!(image64)
    state = put_in(state.out[method], {image, mime})
    if state.subscribed do
      CvWeb.Endpoint.broadcast("notification:#{state.subscribed}", "reload", %{})
    end
    {:reply, nil, state}
  end

  @impl true
  def handle_cast(:process, state) do
    json = Jason.encode!(%{filename: state.name, image: Base.encode64(state.data)})
    headers = [{"Content-type", "application/json"}]

    for {method, url} <- state.methods do
      _task = Task.async(fn ->
        resp = HTTPoison.post!(url, json, headers, [recv_timeout: 60000])
        GenServer.call(__MODULE__, {:process_end, method, resp})
      end)
    end
    {:noreply, state}
  end

  @impl true
  def handle_cast({:subscribe, id}, state) do
    state = put_in(state.subscribed, id)
    {:noreply, state}
  end
end
