defmodule PartyJukebox.QueuedSong do
  use Ecto.Schema
  import Ecto.Changeset

  schema "queued_songs" do
    field :title, :string
    field :artist, :string
    field :added_by, :string
    field :external_id, :string
    field :position, :integer
    
    belongs_to :party, PartyJukebox.Party

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(queued_song, attrs) do
    queued_song
    |> cast(attrs, [:title, :artist, :added_by, :external_id, :position, :party_id])
    |> validate_required([:title, :party_id])
    |> validate_number(:position, greater_than_or_equal_to: 0)
    |> foreign_key_constraint(:party_id)
  end
end