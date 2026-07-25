defmodule MeteoAnalysis.CalculatorTest do
  use ExUnit.Case, async: true

  alias MeteoAnalysis.Calculator

  describe "calculate_average/2" do
    test "calcula a média dos 6 primeiros valores arredondando para 1 casa decimal" do
      temps = [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]
      assert Calculator.calculate_average(temps, 6) == {:ok, 28.5}
    end

    test "ignora os valores além do 6º elemento" do
      temps = [28.5, 29.3, 27.1, 26.8, 29.0, 30.3, 40.0, 50.0]
      assert Calculator.calculate_average(temps, 6) == {:ok, 28.5}
    end

    test "retorna erro quando a lista contém menos de 6 elementos" do
      temps = [28.5, 29.3, 27.1]
      assert Calculator.calculate_average(temps, 6) == {:error, :insufficient_data}
    end

    test "retorna erro para lista vazia" do
      assert Calculator.calculate_average([], 6) == {:error, :insufficient_data}
    end

    test "retorna erro para argumento inválido" do
      assert Calculator.calculate_average(nil, 6) == {:error, :insufficient_data}
    end
  end
end
