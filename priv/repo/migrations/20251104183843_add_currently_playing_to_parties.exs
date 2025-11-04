defmodule PartyJukebox.Repo.Migrations.AddCurrentlyPlayingToParties do
  use Ecto.Migration

  def change do
    alter table(:parties) do
      add :currently_playing_id, references(:queued_songs, on_delete: :nilify_all)
    end

    create index(:parties, [:currently_playing_id])
  end
end