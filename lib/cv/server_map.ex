defmodule Cv.ServerMap do
  use GenServer

  def start_link(state) do
    GenServer.start_link(__MODULE__, state, name: __MODULE__)
  end

  def set(uid, pid) do
    GenServer.cast(__MODULE__, {:set, uid, pid})
  end

  def get(uid) do
    GenServer.call(__MODULE__, {:get, uid})
  end

  @impl true
  def init(state) do
    {:ok, %{}}
  end

  @impl true
  def handle_call({:get, uid}, _from, state) do
    {:reply, state[uid], state}
  end

  @impl true
  def handle_cast({:set, uid, pid}, state) do
    state = put_in(state[uid], pid)
    {:noreply, state}
  end
end
