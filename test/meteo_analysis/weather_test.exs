defmodule MeteoAnalysis.WeatherTest do
  use ExUnit.Case, async: true
  import Mox

  alias MeteoAnalysis.Clients.ClientMock
  alias MeteoAnalysis.Domain.City
  alias MeteoAnalysis.Weather

  setup :set_mox_from_context
  setup :verify_on_exit!

  describe "process_cities/2" do
    test "processa concorrentemente todas as cidades e calcula a temperatura maxima media" do
      sp = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}
      bh = %City{name: "Belo Horizonte", latitude: -19.92, longitude: -43.94}
      cur = %City{name: "Curitiba", latitude: -25.43, longitude: -49.27}

      expect(ClientMock, :fetch_forecast, 3, fn
        %City{name: "São Paulo"} -> {:ok, [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]}
        %City{name: "Belo Horizonte"} -> {:ok, [27.0, 28.0, 27.5, 28.2, 27.8, 28.3]}
        %City{name: "Curitiba"} -> {:ok, [21.5, 22.0, 22.5, 21.8, 22.2, 22.6]}
      end)

      results = Weather.process_cities([sp, bh, cur], ClientMock)

      assert length(results) == 3
      assert {:ok, "São Paulo", 28.5} in results
      assert {:ok, "Belo Horizonte", 27.8} in results
      assert {:ok, "Curitiba", 22.1} in results
    end

    test "retorna erro gracioso para cidade individual sem interromper as demais" do
      sp = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}
      bh = %City{name: "Belo Horizonte", latitude: -19.92, longitude: -43.94}

      expect(ClientMock, :fetch_forecast, 2, fn
        %City{name: "São Paulo"} -> {:ok, [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]}
        %City{name: "Belo Horizonte"} -> {:error, :timeout}
      end)

      results = Weather.process_cities([sp, bh], ClientMock)

      assert {:ok, "São Paulo", 28.5} in results
      assert {:error, "Belo Horizonte", :timeout} in results
    end
  end
end
