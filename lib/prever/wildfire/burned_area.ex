defmodule Prever.Wildfire.BurnedArea do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Prever.Repo

  schema "burned_areas" do
    field :dn, :integer
    field :date, :date
    field :geometry, Geo.PostGIS.Geometry
    field :geom_hash, :binary

    timestamps()
  end

  @doc """
  Changeset para criação de burned_area.
  Calcula automaticamente o geom_hash a partir da geometria.
  """
  def changeset(burned_area \\ %__MODULE__{}, attrs) do
    burned_area
    |> cast(attrs, [:dn, :date, :geometry])
    |> validate_required([:dn, :date, :geometry])
    |> compute_geom_hash()
  end

  def all() do
    query =
      from ba in __MODULE__,
        select: %{
          id: ba.id,
          dn: ba.dn,
          date: ba.date,
          geometry: ba.geometry,
          area: fragment("ST_Area(ST_Transform(?, 6933)) / 10000", ba.geometry)
        }

    Repo.all(query)
    |> Enum.map(fn ba ->
      %{
        geometry: Geo.JSON.encode!(ba.geometry),
        popup:
          "#{ba.id} <br> terrabrasilis - DN: #{ba.dn} - #{ba.date} <br> Area: #{Float.round(ba.area, 2)} hectares",
        area: ba.area
      }
    end)
  end

  defp compute_geom_hash(changeset) do
    case get_change(changeset, :geometry) || get_field(changeset, :geometry) do
      nil ->
        changeset

      geometry ->
        # Converte para GeoJSON string para gerar hash consistente
        geojson_string =
          geometry
          |> Geo.JSON.encode!()
          |> Jason.encode!()

        hash = :crypto.hash(:sha256, geojson_string)
        put_change(changeset, :geom_hash, hash)
    end
  end
end
