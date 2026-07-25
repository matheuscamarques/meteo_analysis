defmodule MeteoAnalysis.Weather do
  @moduledoc """
  Orquestrador de concorrência para busca de dados climáticos e cálculo das médias.
  """

  alias MeteoAnalysis.{City, Calculator}

  @doc """
  Consulta concorrentemente a previsão do tempo de uma lista de cidades e calcula
  a temperatura máxima média para os próximos 6 dias.
  """
  @spec process_cities([City.t()], module()) :: [
          {:ok, String.t(), float()} | {:error, String.t(), term()}
        ]
  def process_cities(
        cities \\ City.default_cities(),
        client \\ MeteoAnalysis.Client.OpenMeteo
      ) do
    cities
    |> Task.async_stream(
      fn city ->
        with {:ok, temps} <- client.fetch_forecast(city),
             {:ok, avg_temp} <- Calculator.calculate_average(temps, 6) do
          {:ok, city.name, avg_temp}
        else
          {:error, reason} -> {:error, city.name, reason}
        end
      end,
      max_concurrency: System.schedulers_online(),
      timeout: 10_000
    )
    |> Enum.map(fn
      {:ok, result} -> result
      {:exit, reason} -> {:error, "Unknown", {:timeout, reason}}
    end)
  end
end
