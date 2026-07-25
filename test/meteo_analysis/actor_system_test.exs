defmodule MeteoAnalysis.ActorSystemTest do
  use ExUnit.Case, async: true
  import Mox

  alias MeteoAnalysis.{City, WeatherCoordinator, WeatherSupervisor, ClientMock}

  setup :set_mox_from_context
  setup :verify_on_exit!

  describe "Sistema de Atores com DynamicSupervisor" do
    test "o DynamicSupervisor esta ativo e registrado sob o nome MeteoAnalysis.WeatherSupervisor" do
      assert Process.whereis(WeatherSupervisor) != nil
    end

    test "o GenServer Coordenador esta ativo e registrado sob o nome MeteoAnalysis.WeatherCoordinator" do
      assert Process.whereis(WeatherCoordinator) != nil
    end

    test "instancia atores trabalhadores dinamicos sob supervisao para cada cidade" do
      sp = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}
      bh = %City{name: "Belo Horizonte", latitude: -19.92, longitude: -43.94}

      expect(ClientMock, :fetch_forecast, 2, fn
        %City{name: "São Paulo"} -> {:ok, [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]}
        %City{name: "Belo Horizonte"} -> {:ok, [27.0, 28.0, 27.5, 28.2, 27.8, 28.3]}
      end)

      results = WeatherCoordinator.process_cities([sp, bh], ClientMock)

      assert length(results) == 2
      assert {:ok, "São Paulo", 28.5} in results
      assert {:ok, "Belo Horizonte", 27.8} in results
    end
  end
end
