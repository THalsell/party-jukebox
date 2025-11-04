defmodule PartyJukebox.Repo do
  use Ecto.Repo,
    otp_app: :party_jukebox,
    adapter: Ecto.Adapters.Postgres
end
