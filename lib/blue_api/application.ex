defmodule BlueApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      BlueApi.Repo,
      # Start the Telemetry supervisor
      BlueApiWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: BlueApi.PubSub},
      # Start the Endpoint (http/https)
      BlueApiWeb.Endpoint,
      {Goth, name: BlueApi.Goth}

      # Start a worker by calling: BlueApi.Worker.start_link(arg)
      # {BlueApi.Worker, arg}
      # BlueApi.Node
      # {Kujira.Invalidator, pubsub: BlueApi.PubSub}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BlueApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BlueApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
