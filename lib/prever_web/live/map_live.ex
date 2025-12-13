defmodule PreverWeb.MapLive do
  use PreverWeb, :live_view

  alias PreverWeb.GoesFireComponent

  require Logger

  def mount(_params, _session, socket) do
    markers = [
      # %{lat: -23.5505, lng: -46.6333, popup: "São Paulo"},
      # %{lat: -22.9068, lng: -43.1729, popup: "Rio de Janeiro"}
    ]

    # Fetch polygons from DB
    burned_areas = Prever.Wildfire.BurnedArea.all()
    total_area_burned = Enum.reduce(burned_areas, 0.0, fn ba, acc -> acc + ba.area end)

    {:ok,
     assign(
       socket,
       init: %{lat: -7.4496, lng: -60.6445, zoom: 5},
       markers: markers,
       burned_areas: burned_areas,
       total_area_burned: total_area_burned,
       period: "2024-08"
     )}
  end

  def render(assigns) do
    ~H"""
    <div style="display: flex; height: 100vh;">
      <div style="width: 70%; min-width: 300px; border-right: 1px solid #1f2630;">
        <div
          id="map-container"
          phx-hook="MapHook"
          data-markers={Jason.encode!(assigns.markers)}
          data-init={Jason.encode!(assigns.init)}
          data-burnedareas={Jason.encode!(assigns.burned_areas)}
          style="width: 100%; height: 100%;"
        >
        </div>
      </div>

      <div style="width: 30%; overflow-y: auto; padding: 1rem;">
        <h3 style="color: red;">
          Área Total com indício de Queimada no Período {@period}: ~{Float.round(
            @total_area_burned,
            2
          )} hectares
        </h3>
        
    <!-- Disclaimer -->
        <p style="font-size: 0.85rem; color: #555; margin-top: 0.5rem;">
          Valor aproximado com base em detecções de satélite não necessariamente refletem área total queimada.
        </p>
        
    <!-- Divider -->
        <hr style="border: 1px solid #1f2630; margin: 1rem 0;" />
        <.live_component
          module={GoesFireComponent}
          id="goes-fire-nsa"
        />
      </div>
    </div>
    """
  end

  def handle_info(:refresh, socket) do
    Logger.debug("Refreshing MapLive")

    send_update(PreverWeb.GoesFireComponent,
      id: "goes-fire-nsa",
      ts: System.system_time(:second)
    )

    {:noreply, socket}
  end
end
