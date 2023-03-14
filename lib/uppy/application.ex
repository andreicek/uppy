defmodule Uppy.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      UppyWeb.Telemetry,
      # Start the Ecto repository
      Uppy.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: Uppy.PubSub},
      # Start Finch
      {Finch, name: Uppy.Finch},
      # Start the Endpoint (http/https)
      UppyWeb.Endpoint,
      {Uppy.Scheduler, [15000, [Uppy.Job.UseCase, :run_all]]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Uppy.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    UppyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
