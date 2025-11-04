defmodule PartyJukeboxWeb.PartyLive.Index do
  use PartyJukeboxWeb, :live_view

  alias PartyJukebox.Parties

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_event("create_party", %{"host_name" => host_name}, socket) do
    case Parties.create_party(%{host_name: host_name}) do
      {:ok, party} ->
        {:noreply, push_navigate(socket, to: ~p"/party/#{party.code}")}
      
      {:error, _changeset} ->
        {:noreply, put_flash(socket, :error, "Failed to create party")}
    end
  end

  @impl true
  def handle_event("join_party", %{"code" => code}, socket) do
    case Parties.get_party_by_code(code) do
      nil ->
        {:noreply, put_flash(socket, :error, "Party not found")}
      
      party ->
        {:noreply, push_navigate(socket, to: ~p"/party/#{party.code}")}
    end
  end
end