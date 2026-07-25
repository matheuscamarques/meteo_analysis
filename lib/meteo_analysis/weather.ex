defmodule MeteoAnalysis.Weather do
  @moduledoc """
  Orquestrador que delega o processamento concorrente ao Sistema de Atores OTP
  gerenciado pelo Coordinator e pelo Supervisor dinamico.
  """

  alias MeteoAnalysis.Domain.City
  alias MeteoAnalysis.Engine.Coordinator

  @doc """
  Consulta concorrentemente a previsão do tempo de uma lista de cidades e calcula
  a temperatura máxima média para os próximos dias utilizando o Modelo de Atores OTP.
  """
  @spec process_cities([City.t()], module() | nil) :: [
          {:ok, String.t(), float()} | {:error, String.t(), term()}
        ]
  def process_cities(
        cities \\ City.default_cities(),
        client \\ nil
      ) do
    target_client =
      client ||
        Application.get_env(
          :meteo_analisys,
          :http_client,
          MeteoAnalysis.Clients.OpenMeteo
        )

    Coordinator.process_cities(cities, target_client)
  end
end
