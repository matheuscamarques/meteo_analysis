defmodule Mix.Tasks.Meteo do
  @moduledoc """
  Task Mix para execução rapida da consulta meteorologica no terminal via `mix meteo`.
  """
  use Mix.Task

  @shortdoc "Executa a consulta de temperatura media para as cidades brasileiras"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("app.start")
    MeteoAnalysis.run()
  end
end
