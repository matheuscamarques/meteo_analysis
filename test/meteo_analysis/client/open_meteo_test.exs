defmodule MeteoAnalysis.Client.OpenMeteoTest do
  use ExUnit.Case, async: true
  import Mox

  alias MeteoAnalysis.City
  alias MeteoAnalysis.Client.OpenMeteo

  setup :verify_on_exit!

  describe "fetch_forecast/1" do
    test "retorna a lista de temperaturas quando o mock responde com sucesso" do
      city = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}

      expect(MeteoAnalysis.ClientMock, :fetch_forecast, fn ^city ->
        {:ok, [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]}
      end)

      assert {:ok, temps} = MeteoAnalysis.ClientMock.fetch_forecast(city)
      assert length(temps) == 6
    end

    test "espera que o cliente real OpenMeteo falhe quando módulo ainda não implementado ou sem rede" do
      city = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}
      # Chama o módulo real que ainda não foi criado
      assert OpenMeteo.fetch_forecast(city) == {:error, :not_implemented}
    end
  end
end
