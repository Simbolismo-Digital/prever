defmodule Prever.Wildfire.FireFocus do
  use Ecto.Schema
  import Ecto.Changeset
  alias Geo.PostGIS.Geometry

  @primary_key {:id, :binary_id, autogenerate: false}
  schema "fire_focus" do
    field :lat, :float
    field :lon, :float
    field :data_hora_gmt, :utc_datetime
    field :satelite, :string
    field :municipio, :string
    field :estado, :string
    field :pais, :string
    field :municipio_id, :integer
    field :estado_id, :integer
    field :pais_id, :integer
    field :numero_dias_sem_chuva, :integer
    field :precipitacao, :float
    field :risco_fogo, :float
    field :bioma, :string
    field :frp, :float
    field :geometry, Geometry

    timestamps()
  end

  @doc """
  Changeset that parses numeric strings to floats/integers
  and creates a geometry POINT from lat/lon.
  """
  def changeset(fire_focus \\ %__MODULE__{}, attrs) do
    attrs =
      parse_numeric_fields(attrs, [
        "lat",
        "lon",
        "estado_id",
        "municipio_id",
        "pais_id",
        "numero_dias_sem_chuva",
        "precipitacao",
        "risco_fogo",
        "frp"
      ])

    fire_focus
    |> cast(attrs, [
      :id,
      :lat,
      :lon,
      :data_hora_gmt,
      :satelite,
      :municipio,
      :estado,
      :pais,
      :municipio_id,
      :estado_id,
      :pais_id,
      :numero_dias_sem_chuva,
      :precipitacao,
      :risco_fogo,
      :bioma,
      :frp
    ])
    |> validate_required([:id, :lat, :lon, :data_hora_gmt, :satelite, :municipio])
    |> put_geometry()
  end

  defp parse_numeric_fields(attrs, keys) do
    Enum.reduce(keys, attrs, fn key, acc ->
      if Map.has_key?(acc, key) do
        value = acc[key]

        parsed =
          cond do
            value in [nil, ""] ->
              nil

            is_binary(value) ->
              value
              |> String.trim()
              |> String.replace(",", ".")
              |> parse_number()

            true ->
              value
          end

        Map.put(acc, key, parsed)
      else
        acc
      end
    end)
  end

  defp parse_number(str) when is_binary(str) do
    str = String.trim(str)

    cond do
      str == "" ->
        nil

      # only digits → integer
      String.match?(str, ~r/^\d+$/) ->
        String.to_integer(str)

      # digits with dot → float
      String.match?(str, ~r/^\d+\.\d+$/) ->
        String.to_float(str)

      true ->
        case Float.parse(str) do
          {num, _} -> num
          :error -> nil
        end
    end
  end

  defp parse_number(n) when is_number(n), do: n
  defp parse_number(_), do: nil

  defp put_geometry(changeset) do
    lat = get_field(changeset, :lat)
    lon = get_field(changeset, :lon)

    if lat && lon do
      geom = %Geo.Point{coordinates: {lon, lat}, srid: 4326}
      put_change(changeset, :geometry, geom)
    else
      changeset
    end
  end
end
