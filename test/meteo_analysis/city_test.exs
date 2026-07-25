defmodule MeteoAnalysis.CityTest do
  use ExUnit.Case, async: true

  alias MeteoAnalysis.City

  describe "default_cities/0" do
    test "retorna a lista com as 3 cidades padrão e suas coordenadas corretas" do
      cities = City.default_cities()

      assert length(cities) == 3

      assert Enum.find(cities, &(&1.name == "São Paulo")) == %City{
               name: "São Paulo",
               latitude: -23.55,
               longitude: -46.63
             }

      assert Enum.find(cities, &(&1.name == "Belo Horizonte")) == %City{
               name: "Belo Horizonte",
               latitude: -19.92,
               longitude: -43.94
             }

      assert Enum.find(cities, &(&1.name == "Curitiba")) == %City{
               name: "Curitiba",
               latitude: -25.43,
               longitude: -49.27
             }
    end
  end
end
