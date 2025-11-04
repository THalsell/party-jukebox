defmodule PartyJukeboxWeb.PartyLive.Show do
  use PartyJukeboxWeb, :live_view

  alias PartyJukebox.Parties

  @impl true
  def mount(%{"code" => code}, _session, socket) do
    case Parties.get_party_by_code(code) do
      nil ->
        {:ok, 
         socket
         |> put_flash(:error, "Party not found")
         |> push_navigate(to: ~p"/")}
      
      party ->
        if connected?(socket) do
          Phoenix.PubSub.subscribe(PartyJukebox.PubSub, "party:#{party.id}")
        end

        queue = Parties.list_queue(party.id)
        
        {:ok,
         socket
         |> assign(:party, party)
         |> assign(:queue, queue)
         |> assign(:guest_name, "")}
    end
  end

  @impl true
  def handle_event("add_song", %{"title" => title, "artist" => artist, "added_by" => added_by}, socket) do
    song_attrs = %{
      title: title,
      artist: artist,
      added_by: added_by,
      external_id: "manual:#{:crypto.strong_rand_bytes(8) |> Base.encode16()}"
    }

    case Parties.add_song_to_queue(socket.assigns.party.id, song_attrs) do
      {:ok, _song} ->
        # Broadcast to all connected clients
        Phoenix.PubSub.broadcast(
          PartyJukebox.PubSub,
          "party:#{socket.assigns.party.id}",
          :queue_updated
        )
        
        {:noreply, socket}
      
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to add song")}
    end
  end

  @impl true
  def handle_info(:queue_updated, socket) do
    queue = Parties.list_queue(socket.assigns.party.id)
    {:noreply, assign(socket, :queue, queue)}
  end
end