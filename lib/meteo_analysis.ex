defmodule MeteoAnalysis do
  @moduledoc """
  Fachada publica (API Boundary) da aplicação Backend Elixir MeteoAnalysis.
  """

  alias MeteoAnalysis.Domain.City
  alias MeteoAnalysis.Weather
  alias MeteoAnalysis.CLI.Formatter

  @doc """
  Ponto de entrada principal da aplicação. Consulta a previsão das cidades padrão,
  calcula as médias e exibe a saída formatada no terminal.
  """
  def run(
        cities \\ City.default_cities(),
        client \\ MeteoAnalysis.Clients.OpenMeteo
      ) do
    results = Weather.process_cities(cities, client)
    output = Formatter.format_all(results)
    IO.puts(output)
    output
  end
end
