defmodule PartyJukebox.Repo.Migrations.CreateParties do
  use Ecto.Migration

  def change do
    create table(:parties) do
      add :code, :string
      add :host_name, :string
      add :status, :string

      timestamps(type: :utc_datetime)
    end

    create unique_index(:parties, [:code])
  end
end
