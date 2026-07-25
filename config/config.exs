import Config

config :meteo_analisys,
  cities: [
    %{name: "São Paulo", latitude: -23.55, longitude: -46.63},
    %{name: "Belo Horizonte", latitude: -19.92, longitude: -43.94},
    %{name: "Curitiba", latitude: -25.43, longitude: -49.27}
  ],
  open_meteo_url: "https://api.open-meteo.com/v1/forecast",
  timezone: "America/Sao_Paulo",
  forecast_days: 6,
  coordinator_timeout: 10_000,
  http_client: MeteoAnalysis.Clients.OpenMeteo

import_config "#{config_env()}.exs"
