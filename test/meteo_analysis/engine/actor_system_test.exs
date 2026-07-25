defmodule MeteoAnalysis.Engine.ActorSystemTest do
  use ExUnit.Case, async: true
  import Mox

  alias MeteoAnalysis.Domain.City
  alias MeteoAnalysis.Engine.{Coordinator, Supervisor}
  alias MeteoAnalysis.Clients.ClientMock

  setup :set_mox_from_context
  setup :verify_on_exit!

  describe "Sistema de Atores Engine" do
    test "o DynamicSupervisor esta ativo e registrado sob o nome MeteoAnalysis.Engine.Supervisor" do
      assert Process.whereis(Supervisor) != nil
    end

    test "o GenServer Coordenador esta ativo e registrado sob o nome MeteoAnalysis.Engine.Coordinator" do
      assert Process.whereis(Coordinator) != nil
    end

    test "instancia atores trabalhadores dinamicos sob supervisao para cada cidade" do
      sp = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}
      bh = %City{name: "Belo Horizonte", latitude: -19.92, longitude: -43.94}

      expect(ClientMock, :fetch_forecast, 2, fn
        %City{name: "São Paulo"} -> {:ok, [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]}
        %City{name: "Belo Horizonte"} -> {:ok, [27.0, 28.0, 27.5, 28.2, 27.8, 28.3]}
      end)

      results = Coordinator.process_cities([sp, bh], ClientMock)

      assert length(results) == 2
      assert {:ok, "São Paulo", 28.5} in results
      assert {:ok, "Belo Horizonte", 27.8} in results
    end
  end
end
