defmodule MeteoAnalysis.Domain.Calculator do
  @moduledoc """
  Módulo de funções puras para cálculos estatísticos da aplicação.
  """

  @type calculation_details :: %{
          daily_max: [float()],
          sum: float(),
          count: pos_integer(),
          average: float()
        }

  @doc """
  Calcula a média aritmética simples dos primeiros `count` elementos de uma lista de números.
  Retorna `{:ok, media}` arredondada em 1 casa decimal ou `{:error, :insufficient_data}`.
  """
  @spec calculate_average([number()], pos_integer()) ::
          {:ok, float()} | {:error, :insufficient_data}
  def calculate_average(temperatures, count \\ 6)

  def calculate_average(temperatures, count)
      when is_list(temperatures) and is_integer(count) and count > 0 do
    case Enum.take(temperatures, count) do
      slice when length(slice) == count ->
        avg = Enum.sum(slice) / count
        {:ok, Float.round(avg, 1)}

      _ ->
        {:error, :insufficient_data}
    end
  end

  def calculate_average(_temperatures, _count), do: {:error, :insufficient_data}

  @doc """
  Calcula a média e retorna a memória de cálculo detalhada incluindo a soma e a lista de temperaturas.
  """
  @spec calculate_details([number()], pos_integer()) ::
          {:ok, calculation_details()} | {:error, :insufficient_data}
  def calculate_details(temperatures, count \\ 6)

  def calculate_details(temperatures, count)
      when is_list(temperatures) and is_integer(count) and count > 0 do
    case Enum.take(temperatures, count) do
      slice when length(slice) == count ->
        sum = Enum.sum(slice)
        avg = sum / count

        {:ok,
         %{
           daily_max: slice,
           sum: Float.round(sum * 1.0, 1),
           count: count,
           average: Float.round(avg, 1)
         }}

      _ ->
        {:error, :insufficient_data}
    end
  end

  def calculate_details(_temperatures, _count), do: {:error, :insufficient_data}
end
