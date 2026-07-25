defmodule MeteoAnalysis.Clients.OpenMeteoTest do
  use ExUnit.Case, async: true
  import Mox

  alias MeteoAnalysis.Clients.ClientMock
  alias MeteoAnalysis.Clients.OpenMeteo
  alias MeteoAnalysis.Domain.City

  setup :verify_on_exit!

  describe "fetch_forecast/1 com Mock" do
    test "retorna a lista de temperaturas quando o mock responde com sucesso" do
      city = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}

      expect(ClientMock, :fetch_forecast, fn ^city ->
        {:ok, [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]}
      end)

      assert {:ok, temps} = ClientMock.fetch_forecast(city)
      assert length(temps) == 6
    end

    test "trata erro HTTP 500 (Internal Server Error) do servidor" do
      city = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}

      expect(ClientMock, :fetch_forecast, fn ^city ->
        {:error, {:http_error, 500}}
      end)

      assert ClientMock.fetch_forecast(city) == {:error, {:http_error, 500}}
    end

    test "trata erro HTTP 429 (Rate Limit Exceeded) de muitas requisições" do
      city = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}

      expect(ClientMock, :fetch_forecast, fn ^city ->
        {:error, {:http_error, 429}}
      end)

      assert ClientMock.fetch_forecast(city) == {:error, {:http_error, 429}}
    end

    test "trata erros de transporte de rede como recusa de conexão e timeout" do
      city = %City{name: "Curitiba", latitude: -25.43, longitude: -49.27}

      expect(ClientMock, :fetch_forecast, fn ^city ->
        {:error, {:network_error, :econnrefused}}
      end)

      assert ClientMock.fetch_forecast(city) == {:error, {:network_error, :econnrefused}}
    end

    test "trata respostas com payload corrompido ou ausência de dados diários" do
      city = %City{name: "Belo Horizonte", latitude: -19.92, longitude: -43.94}

      expect(ClientMock, :fetch_forecast, fn ^city ->
        {:error, :invalid_payload}
      end)

      assert ClientMock.fetch_forecast(city) == {:error, :invalid_payload}
    end
  end

  describe "fetch_forecast/1 real (integração externa)" do
    @tag :integration
    test "retorna temperaturas reais da API Open-Meteo para São Paulo" do
      city = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}

      assert {:ok, temps} = OpenMeteo.fetch_forecast(city)
      assert is_list(temps)
      assert length(temps) >= 6
    end
  end
end
