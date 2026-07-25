defmodule MeteoAnalysis do
  @moduledoc """
  Aplicação Backend Elixir para busca concorrente de previsão do tempo
  e cálculo da temperatura máxima média para cidades brasileiras.
  """

  alias MeteoAnalysis.{City, Weather, Formatter}

  @doc """
  Ponto de entrada principal da aplicação. Consulta a previsão das cidades padrão,
  calcula as médias e exibe a saída formatada no terminal.
  """
  def run(cities \\ City.default_cities(), client \\ MeteoAnalysis.Client.OpenMeteo) do
    results = Weather.process_cities(cities, client)
    output = Formatter.format_all(results)
    IO.puts(output)
    output
  end
end
