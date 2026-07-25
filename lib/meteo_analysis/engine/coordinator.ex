defmodule MeteoAnalysis.Engine.Coordinator do
  @moduledoc """
  Ator Coordenador (`GenServer`) responsavel por gerenciar requisições concorrentes,
  orquestrar a criação de trabalhadores dinâmicos (`MeteoAnalysis.Engine.Worker`)
  e agregar os resultados recebidos na caixa de mensagens (mailbox).

  ## Como funciona a lógica do Coordenador:

  1. **Recepção da Requisição (`process_cities/3`)**:
     - Quando uma chamada é feita para `process_cities/3`, a chamada síncrona `GenServer.call/3`
       é enviada para este processo.

  2. **Inicialização do Estado da Requisição (`handle_call/3`)**:
     - O Coordenador gera uma referência única para o pedido (`req_ref = make_ref()`).
     - O Coordenador **não responde imediatamente** ao cliente. Ele mantém a chamada em aberto
       guardando a tupla `from` (que contém o PID do cliente que está aguardando).
     - Para cada cidade solicitada, o Coordenador pede ao `MeteoAnalysis.Engine.Supervisor`
       para instanciar um novo processo trabalhador `WeatherWorker`.
     - Cada worker recebe o `req_ref` para que saiba a qual pedido responder.
     - É agendado um temporizador de timeout na caixa de mensagens do Coordenador.

  3. **Processamento Assíncrono pelos Atores Trabalhadores**:
     - Cada `WeatherWorker` roda concorrentemente em seu próprio processo BEAM isolado,
       executando a chamada HTTP e o cálculo da média de temperatura.
     - Ao terminar, o worker envia a mensagem `{:worker_result, req_ref, result}` diretamente
       para a caixa de entrada (mailbox) deste Coordenador.

  4. **Agregação de Resultados (`handle_info/2`)**:
     - À medida que as mensagens chegam na mailbox do Coordenador (`handle_info`), o Coordenador
       localiza a requisição correspondente pelo `req_ref`.
     - Adiciona o resultado à lista e decrementa a contagem de tarefas pendentes (`pending`).
     - Quando `pending` chega a 0 (todos os trabalhadores daquele pedido responderam):
       a) O temporizador de timeout é cancelado.
       b) O Coordenador responde ao cliente usando `GenServer.reply(from, results)`.
       c) A requisição é removida do estado interno do Coordenador para liberar memória.

  5. **Tratamento de Timeout (`handle_info({:request_timeout, ...})`)**:
     - Se o tempo limite expirar antes que todos os trabalhadores terminem, o Coordenador
       responde ao cliente com os resultados parciais obtidos até o momento, evitando bloqueios.
  """
  use GenServer
  @compile {:no_warn_undefined, Mox}

  alias MeteoAnalysis.Engine.{Supervisor, Worker}

  @doc """
  Inicia o processo GenServer do Coordenador registrado com o nome do próprio módulo.
  """
  @spec start_link(term()) :: GenServer.on_start()
  def start_link(init_arg \\ []) do
    GenServer.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @doc """
  Função pública de entrada. Envia um pedido síncrono `:process_cities` para o Coordenador.

  ## Parâmetros:
    - `cities`: Lista de structs `MeteoAnalysis.Domain.City`.
    - `client`: Módulo cliente HTTP a ser utilizado.
    - `timeout`: Tempo limite em milissegundos para aguardar todas as respostas (padrão lido das configs).
  """
  @spec process_cities([MeteoAnalysis.Domain.City.t()], module(), pos_integer() | nil) :: [
          {:ok, String.t(), float()} | {:error, String.t(), term()}
        ]
  def process_cities(cities, client \\ nil, timeout \\ nil) do
    target_client =
      client ||
        Application.get_env(
          :meteo_analisys,
          :http_client,
          MeteoAnalysis.Clients.OpenMeteo
        )

    target_timeout =
      timeout || Application.get_env(:meteo_analisys, :coordinator_timeout, 10_000)

    GenServer.call(
      __MODULE__,
      {:process_cities, cities, target_client, target_timeout},
      target_timeout + 2_000
    )
  end

  # --- Callbacks do GenServer ---

  @impl true
  def init(_arg) do
    # O estado do Coordenador mantem um mapa de requisicoes ativas: %{req_ref => dados_da_requisicao}
    {:ok, %{requests: %{}}}
  end

  @doc """
  Callback acionado quando `GenServer.call` envia `{:process_cities, cities, client, timeout}`.
  """
  @impl true
  def handle_call({:process_cities, cities, client, timeout}, {caller_pid, _ref} = from, state) do
    req_ref = make_ref()
    coordinator_pid = self()

    Enum.each(cities, fn city ->
      {:ok, worker_pid} = Supervisor.start_worker(city, client, coordinator_pid, req_ref)
      allow_mox_if_needed(client, caller_pid, worker_pid)
      Worker.execute_fetch(worker_pid)
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

  @doc """
  Callback de mensagens da caixa de entrada (mailbox).
  """
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

  # Função auxiliar para permitir que os trabalhadores acessem mocks em testes com Mox
  defp allow_mox_if_needed(client, caller_pid, worker_pid) do
    if Code.ensure_loaded?(Mox) and function_exported?(Mox, :allow, 3) do
      try do
        Mox.allow(client, caller_pid, worker_pid)
      rescue
        _ -> :ok
      end
    end
  end
end
