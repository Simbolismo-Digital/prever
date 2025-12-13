defmodule Prever.Wildfire.Shapefile do
  alias Exshape.Dbf
  alias Exshape.Shp
  alias Exshape.Shp.Polygon
  alias Exshape.Shp.Point

  def import_stream(path) do
    polygons = load_shape_geojson("#{path}.shp")
    records = load_dbf("#{path}.dbf")

    Stream.zip(polygons, records)
    |> Stream.map(fn {polygon, record} ->
      Map.merge(%{"geometry" => polygon}, record)
    end)
  end

  def import(path) do
    import_stream(path)
    |> Enum.to_list()
  end

  defp load_dbf(path) do
    File.stream!(path, [], 2048)
    |> Dbf.read()
    |> Stream.filter(fn
      record when is_list(record) -> true
      _ -> false
    end)
    |> Stream.map(fn [dn, date_string] ->
      %{
        "dn" => dn,
        "date" =>
          date_string
          |> String.trim()
          |> convert_yyyymmdd_to_date()
      }
    end)
    |> Enum.to_list()
  end

  defp load_shape_geojson(path) do
    File.stream!(path, [], 2048)
    |> Shp.read()
    |> Stream.filter(fn
      %Polygon{} -> true
      _ -> false
    end)
    |> Stream.map(&polygon_to_geojson(&1))
    |> Enum.to_list()
  end

  defp polygon_to_geojson(%Polygon{points: points}) do
    coords =
      points
      |> Enum.map(fn rings ->
        rings
        |> Enum.map(fn ring ->
          ring |> Enum.map(fn %Point{x: x, y: y} -> [x, y] end)
        end)
      end)

    %{
      "type" => "Polygon",
      # pegar apenas o anel externo, se quiser simplificar
      "coordinates" => coords |> List.first()
    }
    |> Geo.JSON.decode!()
  end

  def convert_yyyymmdd_to_date(<<year::binary-4, month::binary-2, day::binary-2>>) do
    # Convert the binary strings (sub-slices of the original string) to integers
    y = String.to_integer(year)
    m = String.to_integer(month)
    d = String.to_integer(day)

    # Use Date.new!/3 to create the Date struct (Date.new/3 returns a {:ok, date} tuple)
    Date.new!(y, m, d)
  end
end
