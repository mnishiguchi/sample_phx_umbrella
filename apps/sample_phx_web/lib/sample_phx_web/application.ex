defmodule SamplePhxWeb.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      SamplePhxWeb.Telemetry,
      # Start the Endpoint (http/https)
      SamplePhxWeb.Endpoint,
      # Start a worker by calling: SamplePhxWeb.Worker.start_link(arg)
      # {SamplePhxWeb.Worker, arg}
      # Start the Presence tracking
      SamplePhxWeb.Presence
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: SamplePhxWeb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    SamplePhxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
