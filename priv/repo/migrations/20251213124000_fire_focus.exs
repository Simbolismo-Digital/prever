defmodule Prever.Repo.Migrations.FireFocus do
  use Ecto.Migration

  def change do
    create table(:fire_focus, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :lat, :float, null: false
      add :lon, :float, null: false
      add :data_hora_gmt, :utc_datetime, null: false
      add :satelite, :string, null: false
      add :municipio, :string, null: false
      add :estado, :string
      add :pais, :string
      add :municipio_id, :integer
      add :estado_id, :integer
      add :pais_id, :integer
      add :numero_dias_sem_chuva, :integer
      add :precipitacao, :float
      add :risco_fogo, :float
      add :bioma, :string
      add :frp, :float

      # PostGIS geometry point (longitude, latitude)
      add :geometry, :geometry, null: false, srid: 4326, type: "Point"

      timestamps()
    end

    # Optional: create an index for fast spatial queries
    create index(:fire_focus, [:geometry], using: :gist)
    create index(:fire_focus, [:data_hora_gmt])
    create index(:fire_focus, [:municipio_id])
  end
end
