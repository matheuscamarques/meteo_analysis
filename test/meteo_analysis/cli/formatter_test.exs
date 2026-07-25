defmodule MeteoAnalysis.CLI.FormatterTest do
  use ExUnit.Case, async: true

  alias MeteoAnalysis.CLI.Formatter

  describe "format_result/1" do
    test "formata o resultado de sucesso no padrao exigido" do
      assert Formatter.format_result({:ok, "São Paulo", 28.5}) == "São Paulo: 28.5°C"
      assert Formatter.format_result({:ok, "Belo Horizonte", 27.8}) == "Belo Horizonte: 27.8°C"
      assert Formatter.format_result({:ok, "Curitiba", 22.1}) == "Curitiba: 22.1°C"
      assert Formatter.format_result({:ok, "São Paulo", 28.5, %{}}) == "São Paulo: 28.5°C"
    end

    test "formata mensagens de erro de forma clara" do
      assert Formatter.format_result({:error, "Curitiba", :network_error}) ==
               "Curitiba: Erro ao obter dados (:network_error)"
    end
  end

  describe "format_all/2 com HUD e Cenários de Falha" do
    test "formata o painel HUD completo contendo a data atual e o tempo de execucao" do
      details = %{
        latitude: -23.55,
        longitude: -46.63,
        daily_max: [28.5, 29.3, 27.1, 26.8, 29.0, 30.3],
        sum: 171.0,
        count: 6
      }

      results = [
        {:ok, "São Paulo", 28.5, details}
      ]

      output = Formatter.format_all(results, 150.25)
      today_str = Date.utc_today() |> Calendar.strftime("%d/%m/%Y")

      assert output =~ "METEO ANALYSIS - TERMINAL HUD"
      assert output =~ "Data de Execução  : #{today_str}"
      assert output =~ "Tempo de Execução : 150.25 ms"
      assert output =~ "CIDADE: São Paulo"
      assert output =~ "Latitude: -23.55 | Longitude: -46.63"
      assert output =~ "[28.5°C, 29.3°C, 27.1°C, 26.8°C, 29.0°C, 30.3°C]"
      assert output =~ "Memória de Cálculo: (28.5 + 29.3 + 27.1 + 26.8 + 29.0 + 30.3) / 6 = 28.5°C"
      assert output =~ "São Paulo: 28.5°C"
    end

    test "renderiza blocos de erro no HUD quando ocorrem falhas de API ou rede" do
      results = [
        {:ok, "São Paulo", 28.5,
         %{
           latitude: -23.55,
           longitude: -46.63,
           daily_max: [28.5, 29.3, 27.1, 26.8, 29.0, 30.3],
           sum: 171.0,
           count: 6
         }},
        {:error, "Belo Horizonte", {:http_error, 500}},
        {:error, "Curitiba", {:network_error, :econnrefused}}
      ]

      output = Formatter.format_all(results, 85.5)

      assert output =~ "CIDADE: São Paulo"
      assert output =~ "CIDADE: Belo Horizonte"
      assert output =~ "Status            : Erro ao obter dados ({:http_error, 500})"
      assert output =~ "CIDADE: Curitiba"
      assert output =~ "Status            : Erro ao obter dados ({:network_error, :econnrefused})"
      assert output =~ "Belo Horizonte: Erro ao obter dados ({:http_error, 500})"
      assert output =~ "Curitiba: Erro ao obter dados ({:network_error, :econnrefused})"
    end

    test "formata bloco HUD para tupla simplificada de 3 elementos" do
      assert Formatter.format_city_hud({:ok, "São Paulo", 28.5}) =~ "CIDADE: São Paulo"

      assert Formatter.format_city_hud({:error, "São Paulo", :timeout}) =~
               "Status            : Erro ao obter dados (:timeout)"
    end

    test "formata HUD quando o tempo de execução é omitido ou nulo" do
      output = Formatter.format_all([{:ok, "São Paulo", 28.5}])
      assert output =~ "Tempo de Execução : N/A"
    end
  end
end
