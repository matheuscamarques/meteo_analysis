defmodule MeteoAnalysis.Engine.Worker do
  @moduledoc """
  Ator Trabalhador (`WeatherWorker`) implementado como um `GenServer` efêmero (`restart: :temporary`).

  ## Como funciona a lógica do Worker:

  1. **Instanciação sob Supervisão (`start_link/1`)**:
     - Cada worker é criado dinamicamente pelo `MeteoAnalysis.Engine.Supervisor` para processar
       uma única cidade.
     - Recebe no `init/1` a tupla `{city, client, coordinator_pid, req_ref}`.

  2. **Execução Solicitada (`execute_fetch/1`)**:
     - O Coordenador aciona `execute_fetch(pid)` após conceder as permissões de teste (Mox).
     - O worker recebe a mensagem `:execute_fetch` via `handle_cast/2`.

  3. **Consulta à API e Cálculo (`handle_cast/2`)**:
     - O worker faz a chamada HTTP usando o cliente injetado (`state.client.fetch_forecast/1`).
     - Calcula a temperatura máxima média dos 6 dias usando `Calculator.calculate_details/2`.
     - Envia a mensagem de resposta `{:ok, city_name, average, details}` diretamente para o Coordenador.

  4. **Encerramento Limpo (`{:stop, :normal, state}`)**:
     - Após enviar o resultado, o processo worker finaliza-se normalmente com `{:stop, :normal, state}`.
     - Como possui a opção `restart: :temporary`, o `DynamicSupervisor` limpa o processo da árvore
       sem tentar reiniciá-lo.
  """
  use GenServer, restart: :temporary

  alias MeteoAnalysis.Domain.Calculator

  @doc """
  Inicia o processo GenServer do trabalhador em um processo isolado.
  """
  @spec start_link({MeteoAnalysis.Domain.City.t(), module(), pid(), reference()}) ::
          GenServer.on_start()
  def start_link({city, client, coordinator_pid, req_ref}) do
    GenServer.start_link(__MODULE__, {city, client, coordinator_pid, req_ref})
  end

  @doc """
  Dispara a requisição de busca e cálculo no worker de forma assíncrona (`cast`).
  """
  @spec execute_fetch(pid()) :: :ok
  def execute_fetch(pid) do
    GenServer.cast(pid, :execute_fetch)
  end

  # --- Callbacks do GenServer ---

  @impl true
  def init({city, client, coordinator_pid, req_ref}) do
    {:ok, %{city: city, client: client, coordinator_pid: coordinator_pid, req_ref: req_ref}}
  end

  @impl true
  def handle_cast(:execute_fetch, state) do
    result =
      with {:ok, temps} <- state.client.fetch_forecast(state.city),
           {:ok, details} <- Calculator.calculate_details(temps, 6) do
        {:ok, state.city.name, details.average,
         %{
           latitude: state.city.latitude,
           longitude: state.city.longitude,
           daily_max: details.daily_max,
           sum: details.sum,
           count: details.count
         }}
      else
        {:error, reason} -> {:error, state.city.name, reason}
      end

    send(state.coordinator_pid, {:worker_result, state.req_ref, result})
    {:stop, :normal, state}
  end
end
