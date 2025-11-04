defmodule PartyJukebox.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PartyJukeboxWeb.Telemetry,
      PartyJukebox.Repo,
      {DNSCluster, query: Application.get_env(:party_jukebox, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: PartyJukebox.PubSub},
      # Start a worker by calling: PartyJukebox.Worker.start_link(arg)
      # {PartyJukebox.Worker, arg},
      # Start to serve requests, typically the last entry
      PartyJukeboxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: PartyJukebox.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PartyJukeboxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
