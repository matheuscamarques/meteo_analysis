defmodule MeteoAnalysis.Client.Behaviour do
  @moduledoc """
  Define o contrato (Behaviour) para clientes HTTP de previsão meteorológica.
  Permite injetar mocks para chamadas assíncronas em testes.
  """

  alias MeteoAnalysis.City

  @callback fetch_forecast(City.t()) :: {:ok, [float()]} | {:error, term()}
end
