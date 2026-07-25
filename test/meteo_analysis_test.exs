defmodule MeteoAnalysisTest do
  use ExUnit.Case, async: true
  import Mox

  alias MeteoAnalysis.Domain.City
  alias MeteoAnalysis.Clients.ClientMock

  setup :set_mox_from_context
  setup :verify_on_exit!

  test "run/2 executa o fluxo completo e retorna o texto formatado" do
    sp = %City{name: "São Paulo", latitude: -23.55, longitude: -46.63}
    bh = %City{name: "Belo Horizonte", latitude: -19.92, longitude: -43.94}
    cur = %City{name: "Curitiba", latitude: -25.43, longitude: -49.27}

    expect(ClientMock, :fetch_forecast, 3, fn
      %City{name: "São Paulo"} -> {:ok, [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]}
      %City{name: "Belo Horizonte"} -> {:ok, [27.8, 28.0, 27.5, 28.2, 27.8, 27.5]}
      %City{name: "Curitiba"} -> {:ok, [22.1, 22.0, 22.5, 21.8, 22.2, 22.0]}
    end)

    output = MeteoAnalysis.run([sp, bh, cur], ClientMock)

    assert output =~ "São Paulo: 28.5°C"
    assert output =~ "Belo Horizonte: 27.8°C"
    assert output =~ "Curitiba: 22.1°C"
  end
end
