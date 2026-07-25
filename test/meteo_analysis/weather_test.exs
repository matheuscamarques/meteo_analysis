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

      assert Enum.any?(results, fn
               {:ok, "São Paulo", 28.5, _} -> true
               _ -> false
             end)

      assert Enum.any?(results, fn
               {:ok, "Belo Horizonte", 27.8, _} -> true
               _ -> false
             end)

      assert Enum.any?(results, fn
               {:ok, "Curitiba", 22.1, _} -> true
               _ -> false
             end)
    end

    test "funciona com a lista de cidades padrao quando invocado apenas com o cliente" do
      expect(ClientMock, :fetch_forecast, 3, fn
        %City{name: "São Paulo"} -> {:ok, [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]}
        %City{name: "Belo Horizonte"} -> {:ok, [27.0, 28.0, 27.5, 28.2, 27.8, 28.3]}
        %City{name: "Curitiba"} -> {:ok, [21.5, 22.0, 22.5, 21.8, 22.2, 22.6]}
      end)

      results = Weather.process_cities(City.default_cities(), ClientMock)
      assert length(results) == 3
    end

    test "funciona sem argumentos invocando as cidades padrao e o cliente HTTP oficial" do
      results = Weather.process_cities()
      assert length(results) == 3
    end

    test "trata falhas parciais (HTTP 500, timeout) isolando os erros por cidade" do
      sp = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}
      bh = %City{name: "Belo Horizonte", latitude: -19.92, longitude: -43.94}
      cur = %City{name: "Curitiba", latitude: -25.43, longitude: -49.27}

      expect(ClientMock, :fetch_forecast, 3, fn
        %City{name: "São Paulo"} -> {:ok, [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]}
        %City{name: "Belo Horizonte"} -> {:error, {:http_error, 500}}
        %City{name: "Curitiba"} -> {:error, :timeout}
      end)

      results = Weather.process_cities([sp, bh, cur], ClientMock)

      assert Enum.any?(results, fn
               {:ok, "São Paulo", 28.5, _} -> true
               _ -> false
             end)

      assert {:error, "Belo Horizonte", {:http_error, 500}} in results
      assert {:error, "Curitiba", :timeout} in results
    end

    test "trata falha total (todas as cidades com erro) sem causar crash nos atores OTP" do
      sp = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}
      bh = %City{name: "Belo Horizonte", latitude: -19.92, longitude: -43.94}

      expect(ClientMock, :fetch_forecast, 2, fn
        %City{name: "São Paulo"} -> {:error, {:network_error, :econnrefused}}
        %City{name: "Belo Horizonte"} -> {:error, {:http_error, 429}}
      end)

      results = Weather.process_cities([sp, bh], ClientMock)

      assert {:error, "São Paulo", {:network_error, :econnrefused}} in results
      assert {:error, "Belo Horizonte", {:http_error, 429}} in results
    end
  end
end
