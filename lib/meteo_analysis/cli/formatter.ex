defmodule MeteoAnalysis.CLI.Formatter do
  @moduledoc """
  Formatador para exibição dos resultados de temperatura e do Painel HUD no terminal.
  """

  @doc """
  Formata um resultado individual de cidade no padrão resumido "Cidade: XX.X°C".
  """
  @spec format_result(term()) :: String.t()
  def format_result({:ok, city_name, temp_avg, _details}) do
    format_result({:ok, city_name, temp_avg})
  end

  def format_result({:ok, city_name, temp_avg}) do
    formatted_temp = :erlang.float_to_binary(temp_avg * 1.0, decimals: 1)
    "#{city_name}: #{formatted_temp}°C"
  end

  def format_result({:error, city_name, reason}) do
    "#{city_name}: Erro ao obter dados (#{inspect(reason)})"
  end

  @doc """
  Formata um resultado individual de cidade no formato de bloco HUD detalhado.
  """
  @spec format_city_hud(term()) :: String.t()
  def format_city_hud({:ok, city_name, temp_avg, details}) do
    temps_str =
      "[" <>
        Enum.map_join(details.daily_max, ", ", fn temp ->
          :erlang.float_to_binary(temp * 1.0, decimals: 1) <> "°C"
        end) <> "]"

    calc_expression =
      Enum.map_join(details.daily_max, " + ", fn temp ->
        :erlang.float_to_binary(temp * 1.0, decimals: 1)
      end)

    formatted_avg = :erlang.float_to_binary(temp_avg * 1.0, decimals: 1)

    """
    --------------------------------------------------------------------------------
     CIDADE: #{city_name}
    --------------------------------------------------------------------------------
     Coordenadas       : Latitude: #{details.latitude} | Longitude: #{details.longitude}
     Temperaturas (6d) : #{temps_str}
     Memória de Cálculo: (#{calc_expression}) / #{details.count} = #{formatted_avg}°C
     Média Máxima      : #{formatted_avg}°C
    --------------------------------------------------------------------------------
    """
    |> String.trim_trailing()
  end

  def format_city_hud({:ok, city_name, temp_avg}) do
    formatted_avg = :erlang.float_to_binary(temp_avg * 1.0, decimals: 1)

    """
    --------------------------------------------------------------------------------
     CIDADE: #{city_name}
    --------------------------------------------------------------------------------
     Média Máxima      : #{formatted_avg}°C
    --------------------------------------------------------------------------------
    """
    |> String.trim_trailing()
  end

  def format_city_hud({:error, city_name, reason}) do
    """
    --------------------------------------------------------------------------------
     CIDADE: #{city_name}
    --------------------------------------------------------------------------------
     Status            : Erro ao obter dados (#{inspect(reason)})
    --------------------------------------------------------------------------------
    """
    |> String.trim_trailing()
  end

  @doc """
  Formata a saída completa incluindo o cabeçalho HUD, detalhamento por cidade e o resumo.
  """
  @spec format_all([term()]) :: String.t()
  def format_all(results) when is_list(results) do
    header = """
    ================================================================================
                           METEO ANALYSIS - TERMINAL HUD                            
    ================================================================================
     Fonte de Dados    : Open-Meteo API (https://open-meteo.com)                    
     Modelo Concorrente: Atores OTP (DynamicSupervisor + GenServers)               
     Janela Analisada  : 6 Dias (Hoje + 5 Dias)                                    
    ================================================================================
    """

    city_huds = Enum.map_join(results, "\n\n", &format_city_hud/1)

    summary_header = """

    ================================================================================
     RESUMO DOS RESULTADOS CALCULADOS
    ================================================================================
    """

    summary_body = Enum.map_join(results, "\n", &format_result/1)

    summary_footer =
      "\n================================================================================"

    header <> "\n" <> city_huds <> summary_header <> summary_body <> summary_footer
  end
end
