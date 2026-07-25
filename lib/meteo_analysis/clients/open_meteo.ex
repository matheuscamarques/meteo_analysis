defmodule MeteoAnalysis.Clients.OpenMeteo do
  @moduledoc """
  Implementação real do cliente HTTP para consumo da API pública Open-Meteo.
  """

  @behaviour MeteoAnalysis.Clients.Behaviour

  alias MeteoAnalysis.Domain.City

  @base_url "https://api.open-meteo.com/v1/forecast"

  @doc """
  Realiza uma chamada HTTP GET para a Open-Meteo API obtendo a lista `temperature_2m_max`.
  """
  @impl true
  def fetch_forecast(%City{latitude: lat, longitude: lon}) do
    params = [
      latitude: lat,
      longitude: lon,
      daily: "temperature_2m_max",
      timezone: "America/Sao_Paulo"
    ]

    case Req.get(@base_url, params: params) do
      {:ok, %Req.Response{status: 200, body: %{"daily" => %{"temperature_2m_max" => temps}}}}
      when is_list(temps) ->
        {:ok, temps}

      {:ok, %Req.Response{status: status}} ->
        {:error, {:http_error, status}}

      {:error, reason} ->
        {:error, {:network_error, reason}}
    end
  end
end
