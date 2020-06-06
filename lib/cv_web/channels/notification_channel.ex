defmodule CvWeb.NotificationChannel do
  use CvWeb, :channel

  @impl true
  def join("notification:lobby", _payload, socket) do
    {:ok, socket}
  end

  @impl true
  def join("notification:"<>uid, _payload, socket) do
    IO.inspect "new ws"
    IO.inspect socket.assigns.user_id
    if uid == to_string(socket.assigns.user_id) do
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("get_status", _payload, socket) do
    pid = Cv.ServerMap.get(socket.assigns.user_id)
    status = Cv.ImageServer.get(pid).status
    IO.inspect "get_status"
    IO.inspect status
    status = for {method, s} <- status, into: %{} do
      case s do
        {:error, _e} -> {method, :error}
        x -> {method, x}
      end
    end
    {:reply, {:ok, %{"status" => status}}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (notification:lobby).
  #@impl true
  #def handle_in("shout", payload, socket) do
  #  broadcast socket, "shout", payload
  #  {:noreply, socket}
  #end
end
