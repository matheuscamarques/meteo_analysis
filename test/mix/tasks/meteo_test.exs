defmodule Mix.Tasks.MeteoTest do
  use ExUnit.Case, async: false

  alias Mix.Tasks.Meteo

  test "run/1 executa a task mix meteo com sucesso e retorna a string do HUD" do
    output = Meteo.run([])
    assert is_binary(output)
    assert output =~ "METEO ANALYSIS - TERMINAL HUD"
  end
end
