import L from "leaflet";

let MapHook = {
  mounted() {
    // Initialize map
    this.map = this.init_map(this.el.dataset.init);

    L.tileLayer("https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png", {
      minZoom: 5,
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
    const map = L.map(this.el, {preferCanvas: true}).setView([init.lat, init.lng], init.zoom);
    // Define os limites máximos que o mapa pode se mover
    const offset = 20; // graus de latitude/longitude que você permite se afastar do centro
    const southWest = [init.lat - offset, init.lng - offset];
    const northEast = [init.lat + offset, init.lng + offset];
    const bounds = L.latLngBounds(southWest, northEast);
    map.setMaxBounds(bounds);
    return map;
  },

  hook_events() {
    // Debug click: show lat/lng
    this.map.on("click", (e) => {
      console.log("Lat:", e.latlng.lat, "Lng:", e.latlng.lng, "Zoom:", this.map.getZoom());
    });

  this.handleEvent("new_fire_geometry", ({ chunk }) => {
    this.renderFireFocus(chunk);
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

    const burnedAreas = JSON.parse(burnedAreasJson);
    burnedAreas.forEach(polygon => {
      const geojsonLayer = L.geoJSON(polygon.geometry, {
        style: { color: 'red', weight: 2, fillOpacity: 0.4 }
      }).bindPopup(polygon.popup).addTo(this.burnedAreasLayer);

      // Bind tooltip to show info on hover
      geojsonLayer.eachLayer(layer => {
        layer.bindTooltip(
          polygon.popup,
          {
            sticky: true,      // tooltip follows the mouse
            direction: 'top',
            className: 'hover-tooltip'
          }
        );
      });
    });
  },

renderFireFocus(fireFocus) {
  if (!this.fireFocusLayer) {
    // Inicializa o layer GeoJSON apenas uma vez
    this.fireFocusLayer = L.geoJSON([], { 
      pointToLayer: (feature, latlng) => 
        L.circleMarker(latlng, {
          radius: 0.4 / (30 / this.map.getZoom()),
          color: 'blue',
          fillColor: 'blue',
          fillOpacity: 1,
          weight: 1
        }),
      preferCanvas: true
    }).addTo(this.map);
  }

  // Converte chunk para GeoJSON
  const chunkGeoJSON = {
    type: "FeatureCollection",
    features: fireFocus.map(({coordinates: [lng, lat]}) => ({
      type: "Feature",
      geometry: { type: "Point", coordinates: [lng, lat] },
      properties: {}
    }))
  };

  // Adiciona o chunk ao layer existente
  this.fireFocusLayer.addData(chunkGeoJSON);
}
};

export default MapHook;