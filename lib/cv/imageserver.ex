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
    state = %{data: data, mime: upload.content_type, name: upload.filename}
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

  #@impl true
  #def handle_cast(:process, state) do
  #  #{ret, status} = System.cmd()

  #  task = Task.async(fn ->
  #    Rambo.run("/home/jaume/Sync/proj/tfg/cores/EAST/wrapper.sh", in: state.data)
  #    GenServer.cast(__MODULE__, :process)
  #  end)
  #  {:ok, rambo} = Task.await(task)
  #  IO.inspect rambo
  #  state = Map.put(state, :out, rambo.out)
  #  {:noreply, state}
  #end

  @impl true
  def handle_cast(:process, state) do
    #{ret, status} = System.cmd()
    # desem en un fitxer temporal (si es pot evitar, millor)
    #Temp.track!
    #{:ok, file_path} = Temp.open %{suffix: state.name}, &IO.write(&1, state.data)
    #HTTPoison.start # cal?
    #resp = HTTPoison.post!("https://127.0.0.1:4010", {:multipart,
    #  [{:file, file_path, {"form-data", [name: "file", filename: data.name]}, []},
    #  {:thing, "hrm"}]})
    #Temp.cleanup

    json = Jason.encode!(%{filename: state.name, image: Base.encode64(state.data)})
    headers = [{"Content-type", "application/json"}]
    #resp = HTTPoison.post!("http://127.0.0.1:4010/process", json, headers, [recv_timeout: 60000])
    #%HTTPoison.Response{status_code: 200, body: resp_body} = resp
    #%{"image" => image64 "mime" => mime} = Jason.decode!(resp_body)
    #image = Base.decode64!(image64)
    #state = Map.put(state, :out, image)
    #state = Map.put(state, :out_mime, mime)

    task = Task.async(fn ->
      resp = HTTPoison.post!("http://127.0.0.1:4011/process", json, headers, [recv_timeout: 60000])
      GenServer.cast(__MODULE__, {:process_end, :EAST, resp})
    end)

    #task = Task.async(fn ->
    #  {:ok, rambo} = Rambo.run("/home/jaume/Sync/proj/tfg/cores/EAST/wrapper.sh", in: state.data)
    #  GenServer.cast(__MODULE__, {:process_end, rambo})
    #end)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:process_end, method, response}, state) do
    #IO.inspect response
    %HTTPoison.Response{status_code: 200, body: resp_body} = response
    %{"image" => image64, "mime" => mime} = Jason.decode!(resp_body)
    image = Base.decode64!(image64)
    state = Map.put(state, :out, image)
    state = Map.put(state, :out_mime, mime)
    {:noreply, state}
  end
end
