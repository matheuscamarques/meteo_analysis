defmodule Mix.Tasks.MeteoTest do
  use ExUnit.Case, async: true
  import Mox

  alias Mix.Tasks.Meteo

  setup :set_mox_from_context

  test "run/1 executa a task mix meteo com sucesso e retorna a string do HUD" do
    stub(MeteoAnalysis.Clients.ClientMock, :fetch_forecast, fn _city ->
      {:ok, [25.0, 26.0, 27.0, 28.0, 29.0, 30.0]}
    end)

    output = Meteo.run([])
    assert is_binary(output)
    assert output =~ "METEO ANALYSIS - TERMINAL HUD"
  end
end
