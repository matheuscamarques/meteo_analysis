defmodule MeteoAnalysis.Domain.CalculatorTest do
  use ExUnit.Case, async: true

  alias MeteoAnalysis.Domain.Calculator

  describe "calculate_average/2" do
    test "calcula a media dos 6 primeiros valores arredondando para 1 casa decimal" do
      temps = [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]
      assert Calculator.calculate_average(temps, 6) == {:ok, 28.5}
    end

    test "ignora os valores alem do 6º elemento" do
      temps = [28.5, 29.3, 27.1, 26.8, 29.0, 30.3, 40.0, 50.0]
      assert Calculator.calculate_average(temps, 6) == {:ok, 28.5}
    end

    test "retorna erro quando a lista contem menos de 6 elementos" do
      temps = [28.5, 29.3, 27.1]
      assert Calculator.calculate_average(temps, 6) == {:error, :insufficient_data}
    end

    test "retorna erro para lista vazia" do
      assert Calculator.calculate_average([], 6) == {:error, :insufficient_data}
    end

    test "retorna erro para argumento invalido" do
      assert Calculator.calculate_average(nil, 6) == {:error, :insufficient_data}
    end
  end

  describe "calculate_details/2" do
    test "retorna o mapa completo da memoria de calculo das temperaturas" do
      temps = [28.5, 29.3, 27.1, 26.8, 29.0, 30.3]

      assert {:ok, details} = Calculator.calculate_details(temps, 6)
      assert details.daily_max == temps
      assert details.sum == 171.0
      assert details.count == 6
      assert details.average == 28.5
    end
  end
end
