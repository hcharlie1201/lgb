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

    setMarkerClusterer(markerClusterer) {
        this.markerClusterer = markerClusterer;

        // Add any existing markers to the clusterer
        if (this.markerClusterer && Object.keys(this.markers).length > 0) {
            const markerArray = Object.values(this.markers);
            this.markerClusterer.addMarkers(markerArray);
        }
    }

    syncMarkersFromDOM() {
        const locationElements = document.querySelectorAll('#location-markers > div');
        const currentIds = new Set();
        let markersChanged = false;

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
                    markersChanged = true;
                }
            } catch (e) {
                console.error("Error parsing location data:", e);
            }
        });

        // Remove markers that no longer exist in the DOM
        Object.keys(this.markers).forEach(id => {
            if (!currentIds.has(parseInt(id))) {
                this.removeMarker(id);
                markersChanged = true;
            }
        });

        // If markers changed and we're not adding/removing markers individually,
        // sync with clusterer
        if (markersChanged && !this.addingToClustererIndividually) {
            this.syncWithClusterer();
        }
    }

    addMarker(location) {
        const position = new google.maps.LatLng(
            parseFloat(location.latitude),
            parseFloat(location.longitude)
        );

        // Create circular image for the marker
        const tempImg = createCircularImageMarker(location.url)

        tempImg.style.opacity = '0';

        // Add animation end listener
        tempImg.addEventListener('animationend', (event) => {
            tempImg.classList.remove('drop');
            tempImg.style.opacity = '1';
        });

        // Add a slight random delay for a staggered effect
        const time = 0.2 + Math.random() * 0.3;
        tempImg.style.setProperty('--delay-time', time + 's');


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

        // Add to clusterer if available
        if (this.markerClusterer) {
            this.markerClusterer.addMarker(marker);
        }

        // Observe for intersection
        if (!this.intersectionObserver) {
            this.intersectionObserver = new IntersectionObserver((entries) => {
                for (const entry of entries) {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('drop');
                        this.intersectionObserver.unobserve(entry.target);
                    }
                }
            });
        }

        // Start observing the marker's content
        this.intersectionObserver.observe(tempImg);
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
            // Remove from clusterer if available
            if (this.markerClusterer) {
                this.markerClusterer.removeMarker(this.markers[id]);
            }
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

    syncWithClusterer() {
        if (!this.markerClusterer) return;

        // Clear existing markers from clusterer
        this.markerClusterer.clearMarkers();

        // Add all current markers to clusterer
        const markerArray = Object.values(this.markers);
        this.markerClusterer.addMarkers(markerArray);
    }
}

export default MarkerManager;