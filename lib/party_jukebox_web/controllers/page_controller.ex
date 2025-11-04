defmodule PartyJukeboxWeb.PageController do
  use PartyJukeboxWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
