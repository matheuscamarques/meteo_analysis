defmodule MeteoAnalysis.Application do
  @moduledoc """
  Modulo Application OTP que inicia a árvore de supervisão principal do sistema de atores.
  """
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MeteoAnalysis.WeatherSupervisor,
      MeteoAnalysis.WeatherCoordinator
    ]

    opts = [strategy: :one_for_one, name: MeteoAnalysis.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
