defmodule MeteoAnalysis.Clients.Behaviour do
  @moduledoc """
  Define o contrato (Behaviour) para clientes HTTP de previsão meteorológica.
  """

  alias MeteoAnalysis.Domain.City

  @callback fetch_forecast(City.t()) :: {:ok, [float()]} | {:error, term()}
end
