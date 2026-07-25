# Kanban Board - Projetos Backend Elixir (MeteoAnalysis)

Este documento contém o Quadro Kanban do projeto, com todas as 16 tarefas granulares (Bite-Sized Tasks) concluídas com sucesso seguindo o ciclo TDD (Red, Green, Refactor) e a estratégia de Git Event Store.

---

## Quadro Kanban de Tarefas (Status Final)

### 1. SETUP & INFRAESTRUTURA
* [x] **TASK-01**: Inicializar o projeto Elixir com Mix (`chore: initialize elixir project with mix new`)
* [x] **TASK-02**: Configurar Dependências do Projeto (`chore(deps): add req, jason and mox dependencies`)

### 2. MÓDULO CITY & DOMÍNIO
* [x] **TASK-03**: [RED] Criar Teste de Validação da Struct `City` (`test(city): add test for default cities struct [RED]`)
* [x] **TASK-04**: [GREEN] Implementar Módulo `MeteoAnalysis.City` (`feat(city): implement City struct and default coordinates [GREEN]`)

### 3. MÓDULO CALCULATOR (LÓGICA MATEMÁTICA PURA)
* [x] **TASK-05**: [RED] Escrever Testes Unitários do Cálculo da Média (`test(calculator): add tests for average calculation of max temps [RED]`)
* [x] **TASK-06**: [GREEN] Implementar Função `calculate_average/2` (`feat(calculator): implement calculate_average/2 [GREEN]`)
* [x] **TASK-07**: [REFACTOR] Otimizar Código do Calculator (`refactor(calculator): optimize pipeline using Enum.take and Float.round [REFACTOR]`)

### 4. INTEGRACAO HTTP & MOX CLIENT
* [x] **TASK-08**: [RED] Criar Behaviour do Cliente HTTP e Teste com Mox (`test(client): define client behaviour and contract test with Mox [RED]`)
* [x] **TASK-09**: [GREEN] Implementar Cliente HTTP Real (`feat(client): implement OpenMeteo client using Req [GREEN]`)

### 5. ORQUESTRADOR CONCORRENTE (`Task.async_stream`)
* [x] **TASK-10**: [RED] Escrever Testes de Concorrência do `Weather` (`test(weather): add test for concurrent processing of cities [RED]`)
* [x] **TASK-11**: [GREEN] Implementar Orquestrador `MeteoAnalysis.Weather.process_cities/2` (`feat(weather): implement process_cities/2 using Task.async_stream [GREEN]`)
* [x] **TASK-12**: [REFACTOR] Tratar Timeouts e Erros com Syntax `with` (`refactor(weather): improve error handling with pattern matching and timeouts [REFACTOR]`)

### 6. FORMATACAO E CLI MAIN ENTRYPOINT
* [x] **TASK-13**: [RED] Escrever Teste do Formatador de Console (`test(formatter): add test for output string formatting [RED]`)
* [x] **TASK-14**: [GREEN] Implementar `MeteoAnalysis.Formatter` (`feat(formatter): implement output console formatter [GREEN]`)
* [x] **TASK-15**: Integrar Ponto de Entrada `MeteoAnalysis.run/0` (`feat(cli): connect entrypoint MeteoAnalysis.run/0`)

### 7. DOCUMENTACAO & FINALIZACAO
* [x] **TASK-16**: Escrever README.md e Checklist de Entrega (`docs: update REQUIREMENTS.md and README.md`)

---

## Matriz de Progresso Final (100% Concluído)

```text
[  Done  ] TASK-01 (Setup Mix)
[  Done  ] TASK-02 (Deps Config)
[  Done  ] TASK-03 (RED: City Test)
[  Done  ] TASK-04 (GREEN: City Module)
[  Done  ] TASK-05 (RED: Calculator Test)
[  Done  ] TASK-06 (GREEN: Calculator Module)
[  Done  ] TASK-07 (REFACTOR: Calculator Pipeline)
[  Done  ] TASK-08 (RED: Client Behaviour Test)
[  Done  ] TASK-09 (GREEN: OpenMeteo Client)
[  Done  ] TASK-10 (RED: Weather Concurrency Test)
[  Done  ] TASK-11 (GREEN: Task.async_stream Weather)
[  Done  ] TASK-12 (REFACTOR: Weather Resiliency)
[  Done  ] TASK-13 (RED: Formatter Test)
[  Done  ] TASK-14 (GREEN: Formatter Module)
[  Done  ] TASK-15 (FEAT: CLI Entrypoint)
[  Done  ] TASK-16 (DOCS: README & Release)
```
