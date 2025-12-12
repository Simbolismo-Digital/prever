defmodule PreverWeb.MapLive do
  use PreverWeb, :live_view

  def mount(_params, _session, socket) do
    # Example state: some markers
    markers = [
      %{lat: -23.5505, lng: -46.6333, popup: "São Paulo"},
      %{lat: -22.9068, lng: -43.1729, popup: "Rio de Janeiro"}
    ]

    {:ok, assign(socket, markers: markers)}
  end

  def render(assigns) do
    ~H"""
    <div
      id="map-container"
      phx-hook="MapHook"
      data-markers={Jason.encode!(assigns.markers)}
      style="height: 100vh;"
    >
    </div>
    """
  end
end
