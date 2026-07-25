defmodule MeteoAnalysis.WeatherSupervisor do
  @moduledoc """
  Supervisor Dinamico responsavel por instanciar e gerenciar atores trabalhadores em tempo de execução.
  """
  use DynamicSupervisor

  def start_link(init_arg \\ []) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @doc """
  Inicia dinamicamente um novo ator trabalhador sob supervisão.
  """
  def start_worker(city, client, coordinator_pid, req_ref) do
    spec = {MeteoAnalysis.WeatherWorker, {city, client, coordinator_pid, req_ref}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
