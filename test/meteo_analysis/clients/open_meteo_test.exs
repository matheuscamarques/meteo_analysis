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
