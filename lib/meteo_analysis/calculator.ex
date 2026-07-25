defmodule MeteoAnalysis.Calculator do
  @moduledoc """
  Módulo de funções puras para cálculos estatísticos da aplicação.
  """

  @doc """
  Calcula a média aritmética simples dos primeiros `count` elementos de uma lista de números.
  Retorna `{:ok, media}` arredondada em 1 casa decimal ou `{:error, :insufficient_data}`.
  """
  @spec calculate_average([number()], pos_integer()) :: {:ok, float()} | {:error, :insufficient_data}
  def calculate_average(temperatures, count \\ 6)

  def calculate_average(temperatures, count)
      when is_list(temperatures) and is_integer(count) and count > 0 do
    if length(temperatures) >= count do
      slice = Enum.take(temperatures, count)
      avg = Enum.sum(slice) / count
      {:ok, Float.round(avg, 1)}
    else
      {:error, :insufficient_data}
    end
  end

  def calculate_average(_temperatures, _count), do: {:error, :insufficient_data}
end
