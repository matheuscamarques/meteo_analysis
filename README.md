# MeteoAnalysis - Backend Elixir (Avaliação Técnica)

Aplicação backend em Elixir para consulta concorrente de previsão do tempo nas cidades de São Paulo, Belo Horizonte e Curitiba utilizando a API pública Open-Meteo, com cálculo da temperatura máxima média para os próximos 6 dias (hoje + 5 dias).

---

## Funcionalidades

* **Consumo de API Externa**: Integração com a API pública Open-Meteo (`GET /v1/forecast`).
* **Modelo de Atores & DynamicSupervisor**: Concorrência baseada no Modelo de Atores OTP com `DynamicSupervisor` (`WeatherSupervisor`) e `GenServer` (`WeatherCoordinator` e `WeatherWorker`).
* **Resiliência OTP**: Isolamento de processos e ciclo de vida gerenciado por supervisão dinâmica com estratégias `:one_for_one`.
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

Para rodar todos os testes unitários, de concorrência e do sistema de atores:
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
│   │   ├── application.ex         # Aplicação OTP e Árvore de Supervisão Raiz
│   │   ├── city.ex                # Struct com coordenadas de SP, BH e Curitiba
│   │   ├── calculator.ex          # Função pura de cálculo estatístico de média
│   │   ├── client/
│   │   │   ├── behaviour.ex       # Behaviour do cliente HTTP
│   │   │   └── open_meteo.ex      # Implementação real da chamada Open-Meteo via Req
│   │   ├── weather_supervisor.ex  # DynamicSupervisor de Atores Trabalhadores
│   │   ├── weather_worker.ex      # GenServer Ator Trabalhador por cidade
│   │   ├── weather_coordinator.ex # GenServer Ator Coordenador de requisições
│   │   ├── weather.ex             # Orquestrador delegador para o Sistema de Atores
│   │   └── formatter.ex           # Formatação do texto de saída
│   └── meteo_analysis.ex          # Ponto de entrada principal (MeteoAnalysis.run/0)
├── test/
│   ├── meteo_analysis/
│   │   ├── city_test.exs
│   │   ├── calculator_test.exs
│   │   ├── client/open_meteo_test.exs
│   │   ├── weather_test.exs
│   │   ├── actor_system_test.exs
│   │   └── formatter_test.exs
│   ├── meteo_analysis_test.exs
│   └── test_helper.exs           # Definição do Mock com Mox
├── KANBAN.md                     # Quadro Kanban com as tarefas granulares
├── REQUIREMENTS.md               # Documentação e Requisitos Técnicos
└── README.md
```
