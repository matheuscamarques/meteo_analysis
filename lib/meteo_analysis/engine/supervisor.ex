defmodule MeteoAnalysis.Engine.Supervisor do
  @moduledoc """
  Supervisor Dinamico responsavel por instanciar e gerenciar atores trabalhadores em tempo de execução.
  """
  use DynamicSupervisor

  @doc """
  Inicia o supervisor dinâmico sob a árvore de supervisão raiz.
  """
  @spec start_link(term()) :: Supervisor.on_start()
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
  @spec start_worker(MeteoAnalysis.Domain.City.t(), module(), pid(), reference()) ::
          DynamicSupervisor.on_start_child()
  def start_worker(city, client, coordinator_pid, req_ref) do
    spec = {MeteoAnalysis.Engine.Worker, {city, client, coordinator_pid, req_ref}}
    DynamicSupervisor.start_child(__MODULE__, spec)
  end
end
