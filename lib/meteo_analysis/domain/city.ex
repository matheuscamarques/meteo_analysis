defmodule MeteoAnalysis.Domain.City do
  @moduledoc """
  Representa uma cidade com nome e coordenadas geográficas (latitude e longitude).
  """

  @enforce_keys [:name, :latitude, :longitude]
  defstruct [:name, :latitude, :longitude]

  @type t :: %__MODULE__{
          name: String.t(),
          latitude: float(),
          longitude: float()
        }

  @doc """
  Cria uma nova struct `%MeteoAnalysis.Domain.City{}` a partir de um mapa de atributos.
  """
  @spec new(map()) :: t()
  def new(%{name: name, latitude: lat, longitude: lon}) do
    %__MODULE__{name: name, latitude: lat, longitude: lon}
  end

  @doc """
  Retorna a lista de cidades padrão lidas dinamicamente da configuração da aplicação (`config/config.exs`).
  """
  @spec default_cities() :: [t()]
  def default_cities do
    :meteo_analisys
    |> Application.get_env(:cities, fallback_cities())
    |> Enum.map(&new/1)
  end

  defp fallback_cities do
    [
      %{name: "São Paulo", latitude: -23.55, longitude: -46.63},
      %{name: "Belo Horizonte", latitude: -19.92, longitude: -43.94},
      %{name: "Curitiba", latitude: -25.43, longitude: -49.27}
    ]
  end
end
