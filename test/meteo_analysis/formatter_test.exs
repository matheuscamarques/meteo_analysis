defmodule MeteoAnalysis.FormatterTest do
  use ExUnit.Case, async: true

  alias MeteoAnalysis.Formatter

  describe "format_result/1" do
    test "formata o resultado de sucesso no padrão exigido" do
      assert Formatter.format_result({:ok, "São Paulo", 28.5}) == "São Paulo: 28.5°C"
      assert Formatter.format_result({:ok, "Belo Horizonte", 27.8}) == "Belo Horizonte: 27.8°C"
      assert Formatter.format_result({:ok, "Curitiba", 22.1}) == "Curitiba: 22.1°C"
    end

    test "formata mensagens de erro de forma clara" do
      assert Formatter.format_result({:error, "Curitiba", :network_error}) ==
               "Curitiba: Erro ao obter dados (:network_error)"
    end
  end

  describe "format_all/1" do
    test "formata a lista completa de resultados separando por quebras de linha" do
      results = [
        {:ok, "São Paulo", 28.5},
        {:ok, "Belo Horizonte", 27.8},
        {:ok, "Curitiba", 22.1}
      ]

      expected = "São Paulo: 28.5°C\nBelo Horizonte: 27.8°C\nCuritiba: 22.1°C"
      assert Formatter.format_all(results) == expected
    end
  end
end
