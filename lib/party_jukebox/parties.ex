defmodule PartyJukebox.Parties do
  @moduledoc """
  The Parties context - handles all party and queue operations.
  """

  import Ecto.Query, warn: false
  alias PartyJukebox.Repo
  alias PartyJukebox.{Party, QueuedSong}

  @doc """
  Creates a party with a random code.
  """
  def create_party(attrs \\ %{}) do
    code = generate_party_code()
    
    attrs
    |> Map.put(:code, code)
    |> Map.put_new(:status, "active")
    |> then(&Party.changeset(%Party{}, &1))
    |> Repo.insert()
  end

  @doc """
  Gets a party by its code.
  """
  def get_party_by_code(code) do
    Repo.get_by(Party, code: code)
  end

  @doc """
  Adds a song to a party's queue.
  """
  def add_song_to_queue(party_id, song_attrs) do
    position = get_next_position(party_id)
    
    song_attrs
    |> Map.put(:party_id, party_id)
    |> Map.put(:position, position)
    |> then(&QueuedSong.changeset(%QueuedSong{}, &1))
    |> Repo.insert()
  end

  @doc """
  Gets all songs in a party's queue, ordered by position.
  """
  def list_queue(party_id) do
    QueuedSong
    |> where([s], s.party_id == ^party_id)
    |> order_by([s], s.position)
    |> Repo.all()
  end

  # Private helper functions

  defp generate_party_code do
    :crypto.strong_rand_bytes(4)
    |> Base.encode16()
    |> binary_part(0, 6)
  end

  defp get_next_position(party_id) do
    query = from s in QueuedSong,
            where: s.party_id == ^party_id,
            select: max(s.position)
    
    case Repo.one(query) do
      nil -> 0
      max_pos -> max_pos + 1
    end
  end
end