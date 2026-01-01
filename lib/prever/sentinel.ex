defmodule Prever.Sentinel do
  @endpoint "https://planetarycomputer.microsoft.com/api/stac/v1/search"

  def search(geometry, datetime_range, cloud_max \\ 0) do
    body = %{
      "collections" => ["sentinel-2-l2a"],
      "datetime" => datetime_range,
      "query" => %{
        "eo:cloud_cover" => %{"lte" => cloud_max}
      },
      "intersects" => geometry,
      "limit" => 10
    }

    {:ok,
     Req.post!(@endpoint,
       json: body,
       headers: [{"content-type", "application/json"}]
     ).body["features"]}
  end
end
