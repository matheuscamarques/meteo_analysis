defmodule MeteoAnalysis.Domain.CalculatorPropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias MeteoAnalysis.Domain.Calculator

  property "calculate_average/2 sempre produz uma media limitada entre o valor minimo e maximo das temperaturas" do
    check all(temps <- list_of(float(min: -50.0, max: 60.0), min_length: 6, max_length: 30)) do
      {:ok, avg} = Calculator.calculate_average(temps, 6)
      sub_slice = Enum.take(temps, 6)
      min_val = Enum.min(sub_slice)
      max_val = Enum.max(sub_slice)

      assert avg >= min_val - 0.1
      assert avg <= max_val + 0.1
    end
  end

  property "calculate_details/2 preserva os 6 primeiros elementos, a contagem e a soma exata" do
    check all(temps <- list_of(float(min: -50.0, max: 60.0), min_length: 6, max_length: 20)) do
      {:ok, details} = Calculator.calculate_details(temps, 6)
      sub_slice = Enum.take(temps, 6)

      assert details.count == 6
      assert details.daily_max == sub_slice
      assert_in_delta details.sum, Enum.sum(sub_slice), 0.2
      assert_in_delta details.average * 6, details.sum, 0.6
    end
  end
end
