defmodule Cv.ImageServer do
  use GenServer
  require Logger
  require Mogrify

  alias Cv.Methods
  alias Cv.Ratings
  alias Cv.Ratings.Rating

  # client

  def start_link(state) do
    #GenServer.start_link(__MODULE__, state, name: __MODULE__)
    GenServer.start_link(__MODULE__, state)
  end

  def upload(pid, input) do
    GenServer.call(pid, {:upload, input})
  end

  def get(pid) do
    GenServer.call(pid, :get)
  end

  def ping(pid) do
    GenServer.call(pid, :ping)
  end

  def process(pid) do
    GenServer.cast(pid, :process)
  end

  def set_submission(pid, id) do
    GenServer.cast(pid, {:set_submission_id, id})
  end

  def subscribe(pid, id) do
    GenServer.cast(pid, {:subscribe, id})
  end

  def rate(pid, method, rating) do
    GenServer.cast(pid, {:rate, method, rating})
  end

  # server

  @impl true
  def init(state) do
    {:ok, state}
  end

  # if the error happens too fast, the user won't have a ws connected
  # and thus will not reload immediately.
  defp handle_error(state, method, e) do
    Logger.error("error in #{method}: #{inspect(e)}")
    if state.subscribed do
      Logger.info("sending reload cuz error")
      try do
        CvWeb.Endpoint.broadcast("notification:#{state.subscribed}", "reload", %{})
      rescue
        _ -> IO.puts("failed to broadcast error")
      end
    end
    put_in(state.status[method], {:error, e})
  end

  @impl true
  def handle_call({:upload, upload}, _from, _state) do

    #Temp.track!
    #dir_path = Temp.mkdir! "mogrify"

    image = Mogrify.open(upload.path) |> Mogrify.auto_orient()
            |> Mogrify.resize_to_limit("1000x1000")
            |> Mogrify.format("png") |> Mogrify.save

    #Temp.cleanup

    #data = File.read!(upload.path)
    #mime = upload.content_type
    data = File.read!(image.path)
    File.rm(image.path)

    #methods = [
    #  {:EAST, "http://127.0.0.1:4010/process"},
    #  {:AdvancedEAST, "http://127.0.0.1:4011/process"},
    #  {:PixelLink, "http://127.0.0.1:4012/process"}
    #]
    methods = for method <- Methods.list_methods() do
      {String.to_atom(method.name), method.url}
    end

    state = %{data: data, mime: "image/png", name: upload.filename,
      subscribed: nil,
      out: %{},
      status: %{},
      ratings: %{},
      methods: methods,
      submission: nil,
      }
    #GenServer.cast(__MODULE__, :process)
    {:reply, {state.data, state.mime}, state}
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
  def handle_call({:method_started, method}, _from, state) do
    state = put_in(state.status[method], {:running})
    {:reply, nil, state}
  end

  @impl true
  def handle_call({:process_end, method, response}, _from, state) do
    try do
      %HTTPoison.Response{status_code: 200, body: resp_body} = response
      %{"image" => image64, "mime" => mime} = Jason.decode!(resp_body)
      image = Base.decode64!(image64)
      state = put_in(state.out[method], {image, mime})
      state = put_in(state.status[method], {:done})
      if state.subscribed do
        #CvWeb.Endpoint.broadcast("notification:#{state.subscribed}", "reload", %{})
        CvWeb.Endpoint.broadcast("notification:#{state.subscribed}", "image",
          %{"method" => method, "data" => image64, "mime" => mime})
      end
      IO.inspect {:done, method}
      {:reply, nil, state}
    rescue
      e -> {:reply, nil, handle_error(state, method, e)}
    end
  end

  @impl true
  def handle_call({:handle_error, method, e}, _from, state) do
    {:reply, nil, handle_error(state, method, e)}
  end

  # needs subscribe and upload called beforehand,
  # maybe should be a single callback
  @impl true
  def handle_cast(:process, state) do
    json = Jason.encode!(%{filename: state.name, image: Base.encode64(state.data)})
    headers = [{"Content-type", "application/json"}]
    pid = self()

    state = put_in(state.status,
      (for {method, _url} <- state.methods, into: %{}, do: {method, {:running}}))

    for {method, url} <- state.methods do
      #state = put_in(state.status[method], {:running})
      _task = Task.start_link(fn ->
        #GenServer.call(pid, {:method_started, method})
        case HTTPoison.post(url, json, headers, [recv_timeout: 60000]) do
          {:ok, resp} -> GenServer.call(pid, {:process_end, method, resp})
          {:error, e} -> GenServer.call(pid, {:handle_error, method, e})
        end
      end)
    end
    {:noreply, state}
  end

  @impl true
  def handle_cast({:subscribe, id}, state) do
    state = put_in(state.subscribed, id)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:set_submission_id, id}, state) do
    {:noreply, put_in(state.submission, id)}
  end

  @impl true
  def handle_cast({:rate, method, rating}, state) do
    state = put_in(state.ratings[method], rating)
    method_id = Methods.by_name!(Atom.to_string(method)).id
    try do
      {rating, _garbage} = Float.parse(rating)
      rating = round(rating * 2)
      IO.inspect :rating
      IO.inspect rating
      Ratings.set_rating(state.submission, method_id, rating)
    rescue
      e -> Logger.error("error saving rating: #{inspect(e)}")
    end
    {:noreply, state}
  end
end
