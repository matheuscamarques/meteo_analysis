defmodule MeteoAnalysis.Weather do
  @moduledoc """
  Orquestrador que delega o processamento concorrente ao Sistema de Atores OTP
  gerenciado pelo WeatherCoordinator e pelo DynamicSupervisor WeatherSupervisor.
  """

  alias MeteoAnalysis.{City, WeatherCoordinator}

  @doc """
  Consulta concorrentemente a previsão do tempo de uma lista de cidades e calcula
  a temperatura máxima média para os próximos 6 dias utilizando o Modelo de Atores OTP.
  """
  @spec process_cities([City.t()], module()) :: [
          {:ok, String.t(), float()} | {:error, String.t(), term()}
        ]
  def process_cities(
        cities \\ City.default_cities(),
        client \\ MeteoAnalysis.Client.OpenMeteo
      ) do
    WeatherCoordinator.process_cities(cities, client)
  end
end
