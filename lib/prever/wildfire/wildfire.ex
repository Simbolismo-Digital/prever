defmodule Prever.Wildfire do
  alias Prever.Repo
  alias Prever.Wildfire.Shapefile
  alias Prever.Wildfire.BurnedArea

  @doc """
  Load wildfire shapefile
    Prever.Wildfire.import_burned_area()
  """
  def import_burned_area() do
    Shapefile.import_stream("priv/mvp/2024_08_aq1km")
    |> Stream.map(&BurnedArea.changeset(&1))
    |> Enum.each(&Repo.insert!(&1, on_conflict: :nothing, conflict_target: [:geom_hash, :date]))
  end
end
