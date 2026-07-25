# Especificação de Requisitos e Documentação Técnica
## Avaliação Técnica – Backend Elixir (Meteo Analysis)

---

## 1. Visão Geral do Projeto

O objetivo deste projeto é desenvolver uma aplicação backend em **Elixir** que consulte concorrentemente a previsão do tempo para 3 cidades brasileiras (**São Paulo**, **Belo Horizonte** e **Curitiba**) através da API pública **Open-Meteo**, processe os dados de temperatura dos próximos 6 dias (hoje + 5 dias), calcule a temperatura máxima média de cada cidade e exiba o resultado consolidado e formatado no terminal.

O foco principal do desenvolvimento é demonstrar:
* **Estruturação limpa e idiomática de código Elixir com Bounded Contexts**.
* **Modelo de Atores OTP & DynamicSupervisor** (`Engine.Supervisor`, `Engine.Coordinator`, `Engine.Worker`).
* **Conceitos de Programação Funcional** (funções puras, imutabilidade, pipelines `|>`, pattern matching).
* **Tratamento de erros e resiliência** (expressão `with`, fallbacks, timeouts).
* **Estratégia sólida de testes** unitários e de integração utilizando Mocks (`Mox`).
* **Metodologia TDD (Red -> Green -> Refactor)** com **Git atuando como Event Store** e Mix Task nativa (`mix meteo`).

---

## 2. Requisitos do Sistema

### 2.1. Requisitos Funcionais (RF)

| ID | Nome | Descrição |
| :--- | :--- | :--- |
| **RF-001** | **Consulta à API Open-Meteo** | O sistema deve realizar chamadas HTTP `GET` para a API da Open-Meteo obtendo a lista `temperature_2m_max` para o período de 6 dias (hoje + 5 dias). |
| **RF-002** | **Execução Concorrente via Atores** | As requisições HTTP para as cidades configuradas devem ser executadas de forma **concorrente e assíncrona** por Atores OTP sob supervisão dinâmica. |
| **RF-003** | **Cálculo da Temperatura Máxima Média** | O sistema deve extrair os primeiros 6 valores do array `daily.temperature_2m_max` e calcular a média aritmética simples para cada cidade. |
| **RF-004** | **Exibição de Resultados e Mix Task** | O sistema deve exibir os resultados na saída padrão (stdout) e ser executável via `mix meteo` ou `MeteoAnalysis.run()`. |
| **RF-005** | **Suporte às Cidades Especificadas** | O sistema deve conter as coordenadas padrão configuradas: <br> • **São Paulo**: Lat `-23.55`, Long `-46.63`<br> • **Belo Horizonte**: Lat `-19.92`, Long `-43.94`<br> • **Curitiba**: Lat `-25.43`, Long `-49.27` |

---

## 3. Arquitetura Modular e Contextos (Bounded Contexts)

```text
meteo_analysis/
├── lib/
│   ├── meteo_analysis/
│   │   ├── domain/
│   │   │   ├── city.ex               # MeteoAnalysis.Domain.City (Structs)
│   │   │   └── calculator.ex         # MeteoAnalysis.Domain.Calculator (Math)
│   │   ├── clients/
│   │   │   ├── behaviour.ex          # MeteoAnalysis.Clients.Behaviour (Contrato)
│   │   │   └── open_meteo.ex         # MeteoAnalysis.Clients.OpenMeteo (Req HTTP)
│   │   ├── engine/
│   │   │   ├── supervisor.ex         # MeteoAnalysis.Engine.Supervisor (DynamicSupervisor)
│   │   │   ├── coordinator.ex        # MeteoAnalysis.Engine.Coordinator (GenServer)
│   │   │   └── worker.ex             # MeteoAnalysis.Engine.Worker (GenServer)
│   │   ├── cli/
│   │   │   └── formatter.ex          # MeteoAnalysis.CLI.Formatter (Formatador)
│   │   ├── application.ex            # MeteoAnalysis.Application (Root Supervisor)
│   │   └── weather.ex                # MeteoAnalysis.Weather (Orquestrador)
│   ├── mix/
│   │   └── tasks/
│   │       └── meteo.ex              # Mix.Tasks.Meteo (Task `mix meteo`)
│   └── meteo_analysis.ex             # MeteoAnalysis (Facade Boundary)
├── test/
│   ├── meteo_analysis/
│   │   ├── domain/
│   │   │   ├── city_test.exs
│   │   │   └── calculator_test.exs
│   │   ├── clients/
│   │   │   └── open_meteo_test.exs
│   │   ├── engine/
│   │   │   └── actor_system_test.exs
│   │   ├── cli/
│   │   │   └── formatter_test.exs
│   │   └── weather_test.exs
│   ├── meteo_analysis_test.exs
│   └── test_helper.exs
```

---

## 4. Instruções de Execução

### Execução via Mix Task Nativas:
```bash
mix meteo
```

### Execução via Função Elixir Direct:
```bash
mix run -e "MeteoAnalysis.run()"
```

### Execução da Suíte de Testes:
```bash
mix test
```
