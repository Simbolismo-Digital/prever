import L from "leaflet";

let MapHook = {
  mounted() {
    // Initialize map
    this.map = this.init_map(this.el.dataset.init);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      maxZoom: 19,
      attribution: "© OpenStreetMap contributors"
    }).addTo(this.map);

    // Render markers from assigns
    this.renderMarkers(this.el.dataset.markers);
    // Render markers from assigns
    this.renderBurnedAreas(this.el.dataset.burnedareas);

    this.hook_events();
  },
  init_map(initJson) {
    const init = JSON.parse(initJson);
    const map = L.map(this.el).setView([init.lat, init.lng], init.zoom);
    return map;
  },

  hook_events() {
    // Debug click: show lat/lng
    this.map.on("click", (e) => {
      console.log("Lat:", e.latlng.lat, "Lng:", e.latlng.lng);
    });
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

    const markers = JSON.parse(markersJson);
    markers.forEach(m => {
      L.marker([m.lat, m.lng])
        .addTo(this.markerLayer)
        .bindPopup(m.popup);
    });
  },

  renderBurnedAreas(burnedAreasJson) {
    if (this.burnedAreasLayer) {
      this.burnedAreasLayer.clearLayers();
    } else {
      this.burnedAreasLayer = L.layerGroup().addTo(this.map);
    }

    const burnedAreass = JSON.parse(burnedAreasJson);
    burnedAreass.forEach(polygon => {
      const geojsonLayer = L.geoJSON(polygon.geometry, {
        style: { color: 'red', weight: 2, fillOpacity: 0.4 }
      }).bindPopup(polygon.popup);

      geojsonLayer.addTo(this.burnedAreasLayer);
    });
  }
};

export default MapHook;