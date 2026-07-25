defmodule MeteoAnalysis.City do
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
  Retorna as 3 cidades brasileiras padrão configuradas com suas coordenadas geográficas.
  """
  @spec default_cities() :: [t()]
  def default_cities do
    [
      %__MODULE__{name: "São Paulo", latitude: -23.55, longitude: -46.63},
      %__MODULE__{name: "Belo Horizonte", latitude: -19.92, longitude: -43.94},
      %__MODULE__{name: "Curitiba", latitude: -25.43, longitude: -49.27}
    ]
  end
end
