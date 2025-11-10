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

        party = Parties.get_party_with_current_song(party.id)
        queue = Parties.list_queue(party.id)
        qr_code = generate_qr_code(party.code)
        
        {:ok,
         socket
         |> assign(:party, party)
         |> assign(:queue, queue)
         |> assign(:search_results, [])
         |> assign(:currently_playing, party.currently_playing)
         |> assign(:qr_code, qr_code)}
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
  def handle_event("search_youtube", %{"query" => query}, socket) do
    case PartyJukebox.YouTube.search(query, 5) do
      {:ok, results} ->
        {:noreply, assign(socket, :search_results, results)}
      
      {:error, _reason} ->
        {:noreply, 
         socket
         |> put_flash(:error, "Failed to search YouTube")
         |> assign(:search_results, [])}
    end
  end

  @impl true
  def handle_event("add_youtube_song", %{"video_id" => video_id, "title" => title, "channel" => channel, "added_by" => added_by}, socket) do
    song_attrs = %{
      title: title,
      artist: channel,
      added_by: added_by,
      external_id: "youtube:#{video_id}"
    }

    case Parties.add_song_to_queue(socket.assigns.party.id, song_attrs) do
      {:ok, _song} ->
        Phoenix.PubSub.broadcast(
          PartyJukebox.PubSub,
          "party:#{socket.assigns.party.id}",
          :queue_updated
        )
        
        {:noreply, assign(socket, :search_results, [])}
      
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to add song")}
    end
  end

  @impl true
  def handle_event("play_next", _params, socket) do
    {:ok, _party} = Parties.play_next_song(socket.assigns.party.id)
    
    Phoenix.PubSub.broadcast(
      PartyJukebox.PubSub,
      "party:#{socket.assigns.party.id}",
      :playback_updated
    )
    
    {:noreply, socket}
  end

  @impl true
  def handle_event("remove_song", %{"song_id" => song_id}, socket) do
    song_id = String.to_integer(song_id)
    Parties.remove_song(song_id)
    
    Phoenix.PubSub.broadcast(
      PartyJukebox.PubSub,
      "party:#{socket.assigns.party.id}",
      :queue_updated
    )
    
    Phoenix.PubSub.broadcast(
      PartyJukebox.PubSub,
      "party:#{socket.assigns.party.id}",
      :playback_updated
    )
    
    {:noreply, socket}
  end

  @impl true
  def handle_info(:queue_updated, socket) do
    queue = Parties.list_queue(socket.assigns.party.id)
    {:noreply, assign(socket, :queue, queue)}
  end

  @impl true
  def handle_info(:playback_updated, socket) do
    party = Parties.get_party_with_current_song(socket.assigns.party.id)
    queue = Parties.list_queue(socket.assigns.party.id)
    
    {:noreply, 
     socket
     |> assign(:party, party)
     |> assign(:currently_playing, party.currently_playing)
     |> assign(:queue, queue)}
  end

 defp generate_qr_code(party_code) do
  endpoint_config = Application.get_env(:party_jukebox, PartyJukeboxWeb.Endpoint)
  url_config = endpoint_config[:url] || []

  host = url_config[:host] || "localhost"
  scheme = url_config[:scheme] || "http"
  port = url_config[:port]

  url = case {scheme, port} do
    {"https", 443} -> "#{scheme}://#{host}/party/#{party_code}"
    {"http", 80} -> "#{scheme}://#{host}/party/#{party_code}"
    {_, nil} -> "#{scheme}://#{host}/party/#{party_code}"
    {_, port} -> "#{scheme}://#{host}:#{port}/party/#{party_code}"
  end

  url
  |> EQRCode.encode()
  |> EQRCode.svg(width: 200, height: 200, viewbox: true, background_color: "#ffffff", color: "#000000")
end
end