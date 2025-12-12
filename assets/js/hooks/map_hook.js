import L from "leaflet";

let MapHook = {
  mounted() {
    // Initialize map
    this.map = L.map(this.el).setView([-15.7942, -47.8822], 4);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: "© OpenStreetMap contributors"
    }).addTo(this.map);

    // Render markers from assigns
    this.renderMarkers(this.el.dataset.markers);
  },

  updated() {
    // Re-render markers if assigns change
    this.renderMarkers(this.el.dataset.markers);
  },

  renderMarkers(markersJson) {
    if (this.markerLayer) {
      this.markerLayer.clearLayers();
    } else {
      this.markerLayer = L.layerGroup().addTo(this.map);
    }

    let markers = JSON.parse(markersJson);
    markers.forEach(m => {
      L.marker([m.lat, m.lng])
        .addTo(this.markerLayer)
        .bindPopup(m.popup);
    });
  }
};

export default MapHook;