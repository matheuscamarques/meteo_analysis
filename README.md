# MeteoAnalysis - Backend Elixir (Avaliação Técnica)

Aplicação backend em Elixir para consulta concorrente de previsão do tempo nas cidades de São Paulo, Belo Horizonte e Curitiba utilizando a API pública Open-Meteo, com cálculo da temperatura máxima média para os próximos 6 dias (hoje + 5 dias).

---

## Funcionalidades

* **Consumo de API Externa**: Integração com a API pública Open-Meteo (`GET /v1/forecast`).
* **Processamento Concorrente**: Execução paralela sem bloqueios para múltiplas cidades utilizando `Task.async_stream/3` do Elixir/BEAM.
* **Cálculo de Média**: Função pura para extrair os 6 primeiros dias de `temperature_2m_max` e calcular a média simples arredondada em 1 casa decimal.
* **Saída Formatada**: Apresentação dos resultados na saída padrão no formato exigido.
* **Suíte de Testes com Mocks**: Isolamento completo de chamadas de rede nos testes utilizando `Mox` (baseado em `Behaviour`).
* **TDD & Git Event Store**: Histórico de commits granular seguindo o ciclo Red -> Green -> Refactor e a especificação Conventional Commits.

---

## Tecnologias Utilizadas

* **Elixir** `~> 1.14+`
* **Req** `~> 0.5.0` (Cliente HTTP moderno)
* **Jason** `~> 1.4` (Parser JSON)
* **Mox** `~> 1.1` (Mocking baseado em Behaviours para testes)
* **ExUnit** (Framework oficial de testes do Elixir)

---

## Pré-requisitos

* **Elixir** (versão 1.14 ou superior) e **Erlang/OTP** instalados no ambiente.

Verifique a instalação com:
```bash
elixir -v
```

---

## Como Executar a Aplicação

### 1. Clonar o Repositório e Instalar Dependências
```bash
git clone https://github.com/seu-usuario/meteo_analysis.git
cd meteo_analysis
mix deps.get
```

### 2. Executar a Aplicação no Terminal
```bash
mix run -e "MeteoAnalysis.run()"
```

**Exemplo de Saída Esperada no Terminal:**
```text
São Paulo: 24.9°C
Belo Horizonte: 27.5°C
Curitiba: 22.8°C
```

---

## Como Executar a Suíte de Testes

Para rodar todos os testes unitários e de integração:
```bash
mix test
```

Para verificar a formatação do código:
```bash
mix format --check-formatted
```

---

## Estrutura do Projeto

```text
meteo_analysis/
├── lib/
│   ├── meteo_analysis/
│   │   ├── city.ex          # Struct com coordenadas de SP, BH e Curitiba
│   │   ├── calculator.ex    # Função pura de cálculo estatístico de média
│   │   ├── client/
│   │   │   ├── behaviour.ex # Behaviour do cliente HTTP
│   │   │   └── open_meteo.ex# Implementação real da chamada Open-Meteo via Req
│   │   ├── weather.ex       # Orquestrador de concorrência com Task.async_stream
│   │   └── formatter.ex     # Formatação gráfica do texto de saída
│   └── meteo_analysis.ex    # Ponto de entrada principal (MeteoAnalysis.run/0)
├── test/
│   ├── meteo_analysis/
│   │   ├── city_test.exs
│   │   ├── calculator_test.exs
│   │   ├── client/open_meteo_test.exs
│   │   ├── weather_test.exs
│   │   └── formatter_test.exs
│   ├── meteo_analysis_test.exs
│   └── test_helper.exs     # Definição do Mock com Mox
├── KANBAN.md               # Quadro Kanban com as 16 tarefas granulares
├── REQUIREMENTS.md         # Documentação e Requisitos Técnicos
└── README.md
```

---

## Histórico de Commits (Git Event Store)

O repositório foi construído seguindo rigorosamente o ciclo TDD e Conventional Commits:

```text
8927e44 docs: update KANBAN.md with all tasks completed
32748ad docs: update REQUIREMENTS.md and README.md
c063de7 feat(cli): connect entrypoint MeteoAnalysis.run/0
412555c feat(formatter): implement output console formatter [GREEN]
3012c2b test(formatter): add test for output string formatting [RED]
9dd99af refactor(weather): improve error handling with pattern matching and timeouts [REFACTOR]
7cf690e feat(weather): implement process_cities/2 using Task.async_stream [GREEN]
7d74b77 test(weather): add test for concurrent processing of cities [RED]
fdd5f52 feat(client): implement OpenMeteo client using Req [GREEN]
89bfa20 test(client): define client behaviour and contract test with Mox [RED]
86ac86e refactor(calculator): optimize pipeline using Enum.take and Float.round [REFACTOR]
d0d98c2 feat(calculator): implement calculate_average/2 [GREEN]
a404f6f test(calculator): add tests for average calculation of max temps [RED]
608dcb0 feat(city): implement City struct and default coordinates [GREEN]
46476d8 test(city): add test for default cities struct [RED]
29f294e chore(deps): add req, jason and mox dependencies
6f0a7f8 chore: initialize elixir project with mix new
```
