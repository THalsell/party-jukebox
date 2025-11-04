defmodule PartyJukebox.Party do
  use Ecto.Schema
  import Ecto.Changeset

  schema "parties" do
    field :code, :string
    field :host_name, :string
    field :status, :string
    
    has_many :queued_songs, PartyJukebox.QueuedSong

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(party, attrs) do
  party
  |> cast(attrs, [:code, :host_name, :status])
  |> validate_required([:code, :host_name])
  |> validate_inclusion(:status, ["active", "ended"])
  |> unique_constraint(:code)
end
end
