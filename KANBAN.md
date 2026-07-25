# Kanban Board - Projetos Backend Elixir (MeteoAnalysis)

Este documento contém o Quadro Kanban do projeto, dividindo todo o desenvolvimento em tarefas granulares (Bite-Sized Tasks) alinhadas com o ciclo **TDD (Red, Green, Refactor)** e a estratégia de **Git Event Store**.

---

## 📊 Quadro Kanban de Tarefas

### 1. 🏗️ SETUP & INFRAESTRUTURA

#### `TASK-01` - Inicializar o projeto Elixir com Mix
- **Coluna:** ✅ **Done**
- **Tipo:** `Chore`
- **Descrição:** Executar o comando `mix new meteo_analysis` para gerar a estrutura inicial do projeto e configurar o arquivo `.gitignore`.
- **Critérios de Aceite:**
  - Projeto Elixir criado com sucesso.
  - Estrutura base de pastas `lib/`, `test/`, `config/` funcional.
- **Commit:** `chore: initialize elixir project with mix new`

#### `TASK-02` - Configurar Dependências do Projeto (`mix.exs`)
- **Coluna:** 📋 **To Do**
- **Tipo:** `Chore`
- **Descrição:** Adicionar as dependências `:req` (cliente HTTP), `:jason` (parser JSON) e `:mox` (Mocks para testes) no arquivo `mix.exs`.
- **Critérios de Aceite:**
  - `mix deps.get` executa sem erros.
  - `:mox` configurado no escopo `:test`.
- **Commit:** `chore(deps): add req, jason and mox dependencies`

---

### 2. 🌆 MÓDULO CITY & DOMÍNIO

#### `TASK-03` - [RED] Criar Teste de Validação da Struct `City`
- **Coluna:** 📋 **To Do**
- **Tipo:** `Test (RED)`
- **Descrição:** Criar `test/meteo_analysis/city_test.exs` testando a criação da struct `%MeteoAnalysis.City{}` e a função `default_cities/0` contendo SP, BH e Curitiba.
- **Critérios de Aceite:**
  - `mix test test/meteo_analysis/city_test.exs` falha pois a struct e módulo ainda não existem.
- **Commit:** `test(city): add test for default cities struct [RED]`

#### `TASK-04` - [GREEN] Implementar Módulo `MeteoAnalysis.City`
- **Coluna:** 📋 **To Do**
- **Tipo:** `Feat (GREEN)`
- **Descrição:** Implementar a struct `%MeteoAnalysis.City{name, latitude, longitude}` e a função `default_cities/0` com as coordenadas geográficas exigidas.
- **Critérios de Aceite:**
  - `mix test test/meteo_analysis/city_test.exs` passa com sucesso.
- **Commit:** `feat(city): implement City struct and default coordinates [GREEN]`

---

### 3. 🧮 MÓDULO CALCULATOR (LÓGICA MATEMÁTICA PURA)

#### `TASK-05` - [RED] Escrever Testes Unitários do Cálculo da Média
- **Coluna:** 📋 **To Do**
- **Tipo:** `Test (RED)`
- **Descrição:** Criar `test/meteo_analysis/calculator_test.exs` cobrindo:
  - Cálculo exato dos primeiros 6 dias de temperatura máxima.
  - Trata lista com menos de 6 elementos (`{:error, :insufficient_data}`).
  - Arredondamento para 1 casa decimal.
- **Critérios de Aceite:**
  - `mix test test/meteo_analysis/calculator_test.exs` falha.
- **Commit:** `test(calculator): add tests for average calculation of max temps [RED]`

#### `TASK-06` - [GREEN] Implementar Função `calculate_average/2`
- **Coluna:** 📋 **To Do**
- **Tipo:** `Feat (GREEN)`
- **Descrição:** Criar `lib/meteo_analysis/calculator.ex` implementando a função pública `calculate_average(temperatures, count \\ 6)`.
- **Critérios de Aceite:**
  - `mix test test/meteo_analysis/calculator_test.exs` passa verde.
- **Commit:** `feat(calculator): implement calculate_average/2 [GREEN]`

#### `TASK-07` - [REFACTOR] Otimizar Código do Calculator
- **Coluna:** 📋 **To Do**
- **Tipo:** `Refactor`
- **Descrição:** Refatorar a função de cálculo para utilizar pipelines funcionais idiomáticos com `Enum.take/2`, `Enum.sum/1` e `Float.round/2`.
- **Critérios de Aceite:**
  - Código limpo, sem duplicações, 100% dos testes passando.
- **Commit:** `refactor(calculator): optimize pipeline using Enum.take and Float.round [REFACTOR]`

---

### 4. 🌐 INTEGRACAO HTTP & MOX CLIENT

#### `TASK-08` - [RED] Criar Behaviour do Cliente HTTP e Teste com Mox
- **Coluna:** 📋 **To Do**
- **Tipo:** `Test (RED)`
- **Descrição:** Criar `lib/meteo_analysis/client/behaviour.ex` e configurar o Mock no `test_helper.exs`. Escrever contrato em `test/meteo_analysis/client/open_meteo_test.exs`.
- **Critérios de Aceite:**
  - Suíte de testes compila o mock mas falha no teste de contrato do cliente real.
- **Commit:** `test(client): define client behaviour and contract test with Mox [RED]`

#### `TASK-09` - [GREEN] Implementar Cliente HTTP Real (`MeteoAnalysis.Client.OpenMeteo`)
- **Coluna:** 📋 **To Do**
- **Tipo:** `Feat (GREEN)`
- **Descrição:** Implementar chamada HTTP `GET` usando `Req` para a URL `https://api.open-meteo.com/v1/forecast?latitude=...&longitude=...&daily=temperature_2m_max&timezone=America/Sao_Paulo`.
- **Critérios de Aceite:**
  - Retorna `{:ok, temperatures_list}` ou `{:error, reason}`.
- **Commit:** `feat(client): implement OpenMeteo client using Req [GREEN]`

---

### 5. ⚡ ORQUESTRADOR CONCORRENTE (`Task.async_stream`)

#### `TASK-10` - [RED] Escrever Testes de Concorrência do `Weather`
- **Coluna:** 📋 **To Do**
- **Tipo:** `Test (RED)`
- **Descrição:** Criar `test/meteo_analysis/weather_test.exs` testando o processamento assíncrono paralelo de múltiplas cidades injetando o `ClientMock`.
- **Critérios de Aceite:**
  - `mix test test/meteo_analysis/weather_test.exs` falha.
- **Commit:** `test(weather): add test for concurrent processing of cities [RED]`

#### `TASK-11` - [GREEN] Implementar Orquestrador `MeteoAnalysis.Weather.process_cities/2`
- **Coluna:** 📋 **To Do**
- **Tipo:** `Feat (GREEN)`
- **Descrição:** Criar `lib/meteo_analysis/weather.ex` usando `Task.async_stream/3` para consultar a API de cada cidade de forma concorrente e calcular as médias.
- **Critérios de Aceite:**
  - Execução paralela sem bloqueios; testes com Mox passando verde.
- **Commit:** `feat(weather): implement process_cities/2 using Task.async_stream [GREEN]`

#### `TASK-12` - [REFACTOR] Tratar Timeouts e Erros com Syntax `with`
- **Coluna:** 📋 **To Do**
- **Tipo:** `Refactor`
- **Descrição:** Melhorar a resiliência no `Task.async_stream` capturando falhas de rede, respostas nulas e timeouts de processos da BEAM.
- **Critérios de Aceite:**
  - Retorno gracioso `{:error, city_name, reason}` sem dar crash na aplicação.
- **Commit:** `refactor(weather): improve error handling with pattern matching and timeouts [REFACTOR]`

---

### 6. 📺 FORMATACAO E CLI MAIN ENTRYPOINT

#### `TASK-13` - [RED] Escrever Teste do Formatador de Console
- **Coluna:** 📋 **To Do**
- **Tipo:** `Test (RED)`
- **Descrição:** Criar `test/meteo_analysis/formatter_test.exs` validando a string final formatada (ex: `"São Paulo: 28.5°C"`).
- **Critérios de Aceite:**
  - Teste criado e falhando.
- **Commit:** `test(formatter): add test for output string formatting [RED]`

#### `TASK-14` - [GREEN] Implementar `MeteoAnalysis.Formatter`
- **Coluna:** 📋 **To Do**
- **Tipo:** `Feat (GREEN)`
- **Descrição:** Criar `lib/meteo_analysis/formatter.ex` para transformar a lista de resultados em texto pronto para exibição no stdout.
- **Critérios de Aceite:**
  - Formatação exata conforme requisito do desafio.
- **Commit:** `feat(formatter): implement output console formatter [GREEN]`

#### `TASK-15` - Integrar Ponto de Entrada `MeteoAnalysis.run/0`
- **Coluna:** 📋 **To Do**
- **Tipo:** `Feat`
- **Descrição:** Conectar os módulos no `lib/meteo_analysis.ex` para executar a busca, cálculo e `IO.puts` do resultado final.
- **Critérios de Aceite:**
  - `mix run -e "MeteoAnalysis.run()"` imprime a lista no terminal:
    ```text
    São Paulo: 28.5°C
    Belo Horizonte: 27.8°C
    Curitiba: 22.1°C
    ```
- **Commit:** `feat(cli): connect entrypoint MeteoAnalysis.run/0`

---

### 7. 📖 DOCUMENTACAO & FINALIZACAO

#### `TASK-16` - Escrever README.md e Checklist de Entrega
- **Coluna:** 📋 **To Do**
- **Tipo:** `Docs`
- **Descrição:** Criar o `README.md` principal do repositório com instruções de execução, execução de testes (`mix test`) e arquitetura do projeto.
- **Critérios de Aceite:**
  - Documentação completa pronta para submissão no GitHub.
- **Commit:** `docs: update REQUIREMENTS.md and README.md`

---

## 📈 Matriz de Progresso

```text
[  Done  ] TASK-01 (Setup Mix)
[  To Do ] TASK-02 (Deps Config)
[  To Do ] TASK-03 (RED: City Test)
[  To Do ] TASK-04 (GREEN: City Module)
[  To Do ] TASK-05 (RED: Calculator Test)
[  To Do ] TASK-06 (GREEN: Calculator Module)
[  To Do ] TASK-07 (REFACTOR: Calculator Pipeline)
[  To Do ] TASK-08 (RED: Client Behaviour Test)
[  To Do ] TASK-09 (GREEN: OpenMeteo Client)
[  To Do ] TASK-10 (RED: Weather Concurrency Test)
[  To Do ] TASK-11 (GREEN: Task.async_stream Weather)
[  To Do ] TASK-12 (REFACTOR: Weather Resiliency)
[  To Do ] TASK-13 (RED: Formatter Test)
[  To Do ] TASK-14 (GREEN: Formatter Module)
[  To Do ] TASK-15 (FEAT: CLI Entrypoint)
[  To Do ] TASK-16 (DOCS: README & Release)
```
