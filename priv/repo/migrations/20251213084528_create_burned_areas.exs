defmodule Prever.Repo.Migrations.CreateBurnedAreas do
  use Ecto.Migration

  def up do
    # Habilita PostGIS
    execute "CREATE EXTENSION IF NOT EXISTS postgis"

    create table(:burned_areas) do
      add :dn, :integer, null: false
      add :date, :date, null: false
      add :geometry, :geometry, null: false, spatial: true, srid: 4326
      add :geom_hash, :bytea, null: false

      timestamps()
    end

    # Índice espacial
    execute "CREATE INDEX burned_areas_geom_idx ON burned_areas USING GIST(geometry)"

    # Índice único composto para evitar duplicatas na mesma data
    create unique_index(:burned_areas, [:geom_hash, :date])
  end

  def down do
    drop table(:burned_areas)
  end
end
