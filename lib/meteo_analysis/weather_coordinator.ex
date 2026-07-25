defmodule MeteoAnalysis.WeatherCoordinator do
  @moduledoc """
  Ator Coordenador responsavel por gerenciar atores trabalhadores dinamicos e agregar respostas.
  """
  use GenServer

  alias MeteoAnalysis.{WeatherSupervisor, WeatherWorker}

  def start_link(init_arg \\ []) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc """
  Processa uma lista de cidades enviando trabalhos para o DynamicSupervisor e aguardando respostas.
  """
  def process_cities(cities, client \\ MeteoAnalysis.Client.OpenMeteo, timeout \\ 10_000) do
    GenServer.call(__MODULE__, {:process_cities, cities, client, timeout}, timeout + 2_000)
  end

  @impl true
  def init(_arg) do
    {:ok, %{requests: %{}}}
  end

  @impl true
  def handle_call({:process_cities, cities, client, timeout}, {caller_pid, _ref} = from, state) do
    req_ref = make_ref()
    coordinator_pid = self()

    Enum.each(cities, fn city ->
      {:ok, worker_pid} = WeatherSupervisor.start_worker(city, client, coordinator_pid, req_ref)
      allow_mox_if_needed(client, caller_pid, worker_pid)
      WeatherWorker.execute_fetch(worker_pid)
    end)

    timer_ref = Process.send_after(self(), {:request_timeout, req_ref}, timeout)

    new_requests =
      Map.put(state.requests, req_ref, %{
        from: from,
        pending: length(cities),
        results: [],
        timer_ref: timer_ref
      })

    {:noreply, %{state | requests: new_requests}}
  end

  @impl true
  def handle_info({:worker_result, req_ref, result}, state) do
    case Map.fetch(state.requests, req_ref) do
      {:ok, req_data} ->
        new_results = [result | req_data.results]
        new_pending = req_data.pending - 1

        if new_pending <= 0 do
          Process.cancel_timer(req_data.timer_ref)
          GenServer.reply(req_data.from, Enum.reverse(new_results))
          new_requests = Map.delete(state.requests, req_ref)
          {:noreply, %{state | requests: new_requests}}
        else
          new_req_data = %{req_data | results: new_results, pending: new_pending}
          new_requests = Map.put(state.requests, req_ref, new_req_data)
          {:noreply, %{state | requests: new_requests}}
        end

      :error ->
        {:noreply, state}
    end
  end

  @impl true
  def handle_info({:request_timeout, req_ref}, state) do
    case Map.pop(state.requests, req_ref) do
      {%{from: from, results: results}, new_requests} ->
        GenServer.reply(from, Enum.reverse(results))
        {:noreply, %{state | requests: new_requests}}

      {nil, _} ->
        {:noreply, state}
    end
  end

  defp allow_mox_if_needed(client, caller_pid, worker_pid) do
    if Code.ensure_loaded?(Mox) and function_exported?(Mox, :allow, 3) do
      try do
        apply(Mox, :allow, [client, caller_pid, worker_pid])
      rescue
        _ -> :ok
      end
    end
  end
end
