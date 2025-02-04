defmodule Scrabble.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ScrabbleWeb.Telemetry,
      Scrabble.Repo,
      {DNSCluster, query: Application.get_env(:scrabble, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Scrabble.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Scrabble.Finch},
      # Start a worker by calling: Scrabble.Worker.start_link(arg)
      # {Scrabble.Worker, arg},
      # Start to serve requests, typically the last entry
      ScrabbleWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Scrabble.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ScrabbleWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
