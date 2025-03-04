class MapEvents {
    constructor(hook) {
        this.hook = hook;
        this.boundsChangeTimeout = null;
    }

    setMap(map) {
        this.map = map;

        // Add map event listeners
        this.map.addListener("click", (event) => {
            this.hook.handleMapClick(event.latLng);
        });

        this.map.addListener("bounds_changed", () => {
            this.hook.handleBoundsChanged();
        });
    }

    setupEventListeners() {
        // Listen for events to focus on a marker
        window.addEventListener("focus-map-marker", (e) => {
            this.hook.focusMarker(e.detail);
        });

        // LiveView push event handlers
        this.hook.handleEvent("center-map", (data) => {
            this.centerMap(data);
        });

        this.hook.handleEvent("get-user-location", (data) => {
            this.hook.getUserLocation(data);
        });

        this.hook.handleEvent("remove-marker", (data) => {
            this.hook.markerManager.removeMarker(data.id);
        });
    }

    handleMapClick(position) {
        // Send position to the server
        this.hook.pushEvent("location-selected", {
            lat: position.lat().toString(),
            lng: position.lng().toString()
        });

        // Add a marker for the selected position
        this.hook.markerManager.addSelectionMarker(position);
    }

    handleBoundsChanged() {
        // Debounce to avoid too many events
        if (this.boundsChangeTimeout) {
            clearTimeout(this.boundsChangeTimeout);
        }

        this.boundsChangeTimeout = setTimeout(() => {
            const bounds = this.map.getBounds();
            if (!bounds) return;

            const ne = bounds.getNorthEast();
            const sw = bounds.getSouthWest();

            this.hook.pushEvent("map-bounds-changed", {
                bounds: {
                    ne_lat: ne.lat().toString(),
                    ne_lng: ne.lng().toString(),
                    sw_lat: sw.lat().toString(),
                    sw_lng: sw.lng().toString()
                }
            });
        }, 500);
    }

    centerMap(data) {
        this.map.setCenter({
            lat: parseFloat(data.lat),
            lng: parseFloat(data.lng)
        });

        if (data.zoom) {
            this.map.setZoom(data.zoom);
        }
    }
}

export default MapEvents;