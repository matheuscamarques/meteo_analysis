defmodule MeteoAnalysis.CLI.Formatter do
  @moduledoc """
  Formatador para exibição dos resultados de temperatura no terminal.
  """

  @doc """
  Formata um resultado individual de cidade.
  """
  @spec format_result({:ok, String.t(), float()} | {:error, String.t(), term()}) :: String.t()
  def format_result({:ok, city_name, temp_avg}) do
    formatted_temp = :erlang.float_to_binary(temp_avg * 1.0, decimals: 1)
    "#{city_name}: #{formatted_temp}°C"
  end

  def format_result({:error, city_name, reason}) do
    "#{city_name}: Erro ao obter dados (#{inspect(reason)})"
  end

  @doc """
  Formata uma lista de resultados separando cada cidade por quebra de linha.
  """
  @spec format_all([{:ok, String.t(), float()} | {:error, String.t(), term()}]) :: String.t()
  def format_all(results) when is_list(results) do
    results
    |> Enum.map(&format_result/1)
    |> Enum.join("\n")
  end
end
