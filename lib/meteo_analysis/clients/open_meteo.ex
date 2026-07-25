defmodule MeteoAnalysis.Clients.OpenMeteo do
  @moduledoc """
  Implementação real do cliente HTTP para consumo da API pública Open-Meteo com tratamento resiliente de erros.
  """

  @behaviour MeteoAnalysis.Clients.Behaviour

  alias MeteoAnalysis.Domain.City

  @doc """
  Realiza uma chamada HTTP GET para a Open-Meteo API obtendo a lista `temperature_2m_max`.
  Trata erros de HTTP (4xx, 5xx), erros de transporte de rede e payloads malformados.
  """
  @impl true
  def fetch_forecast(%City{latitude: lat, longitude: lon}) do
    base_url =
      Application.get_env(
        :meteo_analisys,
        :open_meteo_url,
        "https://api.open-meteo.com/v1/forecast"
      )

    tz = Application.get_env(:meteo_analisys, :timezone, "America/Sao_Paulo")

    params = [
      latitude: lat,
      longitude: lon,
      daily: "temperature_2m_max",
      timezone: tz
    ]

    case Req.get(base_url, params: params) do
      {:ok, %Req.Response{status: 200, body: %{"daily" => %{"temperature_2m_max" => temps}}}}
      when is_list(temps) ->
        {:ok, temps}

      {:ok, %Req.Response{status: 200}} ->
        {:error, :invalid_payload}

      {:ok, %Req.Response{status: status}} ->
        {:error, {:http_error, status}}

      {:error, %Req.TransportError{reason: reason}} ->
        {:error, {:network_error, reason}}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
