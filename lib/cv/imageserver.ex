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

    task = Task.async(fn ->
      {:ok, rambo} = Rambo.run("/home/jaume/Sync/proj/tfg/cores/EAST/wrapper.sh", in: state.data)
      GenServer.cast(__MODULE__, {:process_end, rambo})
    end)
    {:noreply, state}
  end

  @impl true
  def handle_cast({:process_end, rambo}, state) do
    IO.inspect rambo
    state = Map.put(state, :out, rambo.out)
    {:noreply, state}
  end
end
