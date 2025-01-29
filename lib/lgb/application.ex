defmodule Lgb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      LgbWeb.Telemetry,
      Lgb.Repo,
      {DNSCluster, query: Application.get_env(:lgb, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Lgb.PubSub},
      LgbWeb.Presence,
      # Start the Finch HTTP client for sending emails
      {Finch, name: Lgb.Finch},
      # Start a worker by calling: Lgb.Worker.start_link(arg)
      # {Lgb.Worker, arg},
      # Start to serve requests, typically the last entry
      LgbWeb.Endpoint
    ]

    :logger.add_handler(:my_sentry_handler, Sentry.LoggerHandler, %{
       config: %{metadata: [:file, :line]}
     })

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Lgb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    LgbWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
