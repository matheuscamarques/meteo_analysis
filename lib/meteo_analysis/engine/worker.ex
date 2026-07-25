defmodule MeteoAnalysis.Engine.Worker do
  @moduledoc """
  Ator Trabalhador (Worker Actor) implementado como GenServer temporario supervisionado.
  """
  use GenServer, restart: :temporary

  alias MeteoAnalysis.Domain.Calculator

  @doc """
  Inicia a execução do ator trabalhador com a tupla {city, client, coordinator_pid, req_ref}.
  """
  def start_link({city, client, coordinator_pid, req_ref}) do
    GenServer.start_link(__MODULE__, {city, client, coordinator_pid, req_ref})
  end

  @doc """
  Solicita o inicio do processamento apos o trabalhador ser configurado e ter permissoes atribuidas.
  """
  def execute_fetch(pid) do
    GenServer.cast(pid, :execute_fetch)
  end

  @impl true
  def init({city, client, coordinator_pid, req_ref}) do
    {:ok, %{city: city, client: client, coordinator_pid: coordinator_pid, req_ref: req_ref}}
  end

  @impl true
  def handle_cast(:execute_fetch, state) do
    result =
      with {:ok, temps} <- state.client.fetch_forecast(state.city),
           {:ok, avg_temp} <- Calculator.calculate_average(temps, 6) do
        {:ok, state.city.name, avg_temp}
      else
        {:error, reason} -> {:error, state.city.name, reason}
      end

    send(state.coordinator_pid, {:worker_result, state.req_ref, result})
    {:stop, :normal, state}
  end
end
