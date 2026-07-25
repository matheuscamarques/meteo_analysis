defmodule MeteoAnalysis do
  @moduledoc """
  Fachada publica (API Boundary) da aplicação Backend Elixir MeteoAnalysis.
  """

  alias MeteoAnalysis.CLI.Formatter
  alias MeteoAnalysis.Domain.City
  alias MeteoAnalysis.Weather

  @doc """
  Ponto de entrada principal da aplicação. Consulta a previsão das cidades padrão,
  calcula as médias, mede o tempo de execução e exibe a saída formatada no terminal.
  """
  def run(
        cities \\ City.default_cities(),
        client \\ nil
      ) do
    start_time = System.monotonic_time(:microsecond)
    results = Weather.process_cities(cities, client)
    elapsed_us = System.monotonic_time(:microsecond) - start_time
    execution_time_ms = elapsed_us / 1_000.0

    output = Formatter.format_all(results, execution_time_ms)
    IO.puts(output)
    output
  end
end
