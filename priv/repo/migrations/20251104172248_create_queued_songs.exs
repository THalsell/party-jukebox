defmodule PartyJukebox.Repo.Migrations.CreateQueuedSongs do
  use Ecto.Migration

  def change do
    create table(:queued_songs) do
      add :title, :string
      add :artist, :string
      add :added_by, :string
      add :external_id, :string
      add :position, :integer
      add :party_id, references(:parties, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:queued_songs, [:party_id])
  end
end
