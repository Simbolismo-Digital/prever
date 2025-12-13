require Protocol

Postgrex.Types.define(
  Prever.PostgresTypes,
  [Geo.PostGIS.Extension] ++ Ecto.Adapters.Postgres.extensions(),
  json: Jason
)

Protocol.derive(Jason.Encoder, Geo.Polygon, only: [:coordinates, :srid, :properties])
