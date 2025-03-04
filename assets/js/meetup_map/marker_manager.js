import { createCircularImageMarker, createSelectionMarker } from './marker_style.js';

class MarkerManager {
    constructor(hook) {
        this.hook = hook;
        this.markers = {};
        this.selectionMarker = null;
    }

    setMap(map) {
        this.map = map;
    }

    syncMarkersFromDOM() {
        const locationElements = document.querySelectorAll('#location-markers > div');
        const currentIds = new Set();

        // Add or update markers
        locationElements.forEach(element => {
            try {
                const locationData = JSON.parse(element.dataset.location);
                currentIds.add(locationData.id);

                if (this.markers[locationData.id]) {
                    // Update existing marker if needed
                    this.updateMarker(locationData);
                } else {
                    // Create new marker
                    this.addMarker(locationData);
                }
            } catch (e) {
                console.error("Error parsing location data:", e);
            }
        });

        // Remove markers that no longer exist in the DOM
        Object.keys(this.markers).forEach(id => {
            if (!currentIds.has(parseInt(id))) {
                this.removeMarker(id);
            }
        });
    }

    addMarker(location) {
        const position = new google.maps.LatLng(
            parseFloat(location.latitude),
            parseFloat(location.longitude)
        );

        // Create circular image for the marker
        const tempImg = createCircularImageMarker(location.url)

        const marker = new google.maps.marker.AdvancedMarkerElement({
            position,
            map: this.map,
            title: location.title || location.name,
            content: tempImg
        });

        // Add click handler
        marker.addListener("gmp-click", () => {
            this.hook.pushEvent("open-location-modal", {
                location_id: location.id
            });
        });

        // Store the marker
        this.markers[location.id] = marker;
    }

    updateMarker(location) {
        const marker = this.markers[location.id];
        if (!marker) return;

        // Update title if needed
        if (marker.title !== (location.title || location.name)) {
            marker.title = location.title || location.name;
        }

        // Update the image if needed
        if (marker.content && marker.content.tagName === 'IMG' &&
            marker.content.src !== location.url) {
            marker.content.src = location.url;
        }
    }

    removeMarker(id) {
        if (this.markers[id]) {
            this.markers[id].map = null;
            delete this.markers[id];
        }
    }

    focusMarker({ id, lat, lng }) {
        this.map.setCenter({ lat: parseFloat(lat), lng: parseFloat(lng) });
        this.map.setZoom(15);

        // Highlight the marker
        const marker = this.markers[id];
        if (marker && marker.content) {
            // Reset after animation
            setTimeout(() => {
                marker.content.style.border = originalBorder;
                marker.content.style.width = originalWidth;
                marker.content.style.height = originalHeight;
            }, 1500);
        }
    }

    addSelectionMarker(position) {
        // IMPORTANT: First properly remove the existing marker
        if (this.selectionMarker) {
            this.selectionMarker.map = null;
        }

        // Create the circular image marker content
        const markerContent = createSelectionMarker();

        // Create a new marker
        this.selectionMarker = new google.maps.marker.AdvancedMarkerElement({
            position: position,
            content: markerContent
        });

        // Add the marker to the map
        this.selectionMarker.map = this.map;
    }
}

export default MarkerManager;