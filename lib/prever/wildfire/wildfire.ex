defmodule Prever.Wildfire do
  alias Prever.Repo
  alias Prever.Wildfire.Csv
  alias Prever.Wildfire.BurnedArea
  alias Prever.Wildfire.FireFocus
  alias Prever.Wildfire.Shapefile

  @doc """
  Load wildfire shapefile
    Prever.Wildfire.import_burned_area()
  """
  def import_burned_area() do
    Shapefile.import_stream("priv/mvp/2024_08_aq1km")
    |> Stream.map(&BurnedArea.changeset(&1))
    |> Enum.each(&Repo.insert!(&1, on_conflict: :nothing, conflict_target: [:geom_hash, :date]))
  end

  @doc """
  Load wildfire focus
    Prever.Wildfire.import_fire_focus()
  """
  def import_fire_focus() do
    Csv.load("priv/mvp/focos_mensal_br_202408.csv")
    |> Stream.map(&FireFocus.changeset(&1))
    |> Stream.filter(&(&1.valid? == true))
    |> Enum.each(&Repo.insert!(&1, on_conflict: :nothing, conflict_target: [:id]))
  end
end
