const MeetupMap = {
    mounted() {
        // Store markers in an object map keyed by location ID for easy lookup
        this.markers = {};
        this.userLocationMarker = null;

        // Load Google Maps
        this.loadGoogleMaps();

        // Set up event listeners
        this.setupEventListeners();

        // Set up mutation observer for location streams
        this.setupLocationObserver();
    },

    loadGoogleMaps() {
        const apiKey = this.el.dataset.apiKey;

        if (window.google && window.google.maps) {
            this.initMap();
        } else {
            const script = document.createElement('script');
            script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&callback=initGoogleMaps`;
            script.async = true;

            window.initGoogleMaps = () => {
                this.initMap();
            };

            document.head.appendChild(script);
        }
    },

    setupEventListeners() {
        // Listen for events to focus on a marker
        window.addEventListener("focus-map-marker", (e) => {
            this.focusMarker(e.detail);
        });

        // LiveView push event handlers
        this.handleEvent("center-map", (data) => {
            this.centerMap(data);
        });

        this.handleEvent("get-user-location", (data) => {
            this.getUserLocation(data);
        });

        this.handleEvent("remove-marker", (data) => {
            this.removeMarker(data.id);
        });
    },

    setupLocationObserver() {
        // Use this if you're using streams for locations
        const locationContainer = document.getElementById('location-markers');
        if (!locationContainer) return;

        const observer = new MutationObserver(() => {
            this.syncMarkersFromDOM();
        });

        observer.observe(locationContainer, { childList: true, subtree: true });

        // Initial sync
        this.syncMarkersFromDOM();
    },

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
    },

    initMap() {
        // Default map center
        const defaultCenter = { lat: 37.7749, lng: -122.4194 };

        // Create the map
        this.map = new google.maps.Map(this.el, {
            zoom: 12,
            center: defaultCenter,
            styles: [
                // Add custom map styles if desired
            ]
        });

        // Add click listener to map
        this.map.addListener("click", (event) => {
            this.handleMapClick(event.latLng);
        });

        // Add bounds_changed listener
        this.map.addListener("bounds_changed", () => {
            this.handleBoundsChanged();
        });

        // Try to get user's current location
        this.tryGetUserInitialLocation();
    },

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

            this.pushEvent("map-bounds-changed", {
                bounds: {
                    ne_lat: ne.lat().toString(),
                    ne_lng: ne.lng().toString(),
                    sw_lat: sw.lat().toString(),
                    sw_lng: sw.lng().toString()
                }
            });
        }, 500);
    },

    handleMapClick(position) {
        // Send position to the server
        this.pushEvent("location-selected", {
            lat: position.lat().toString(),
            lng: position.lng().toString()
        });

        // Remove previous selection marker if any
        if (this.selectionMarker) {
            this.selectionMarker.setMap(null);
        }

        // Add a marker for the selected position
        this.selectionMarker = new google.maps.Marker({
            position,
            map: this.map,
            animation: google.maps.Animation.DROP,
            icon: this.getMarkerIcon('selection')
        });
    },

    addMarker(location) {
        const position = new google.maps.LatLng(
            parseFloat(location.latitude),
            parseFloat(location.longitude)
        );

        // Determine marker icon based on status
        const iconType = this.getMarkerTypeForLocation(location);

        const marker = new google.maps.Marker({
            position,
            map: this.map,
            title: location.title || location.name,
            icon: this.getMarkerIcon(iconType)
        });

        // Add click handler
        marker.addListener("click", () => {
            this.pushEvent("open-location-modal", {
                location_id: location.id
            });
        });

        // Store the marker
        this.markers[location.id] = marker;
    },

    updateMarker(location) {
        const marker = this.markers[location.id];
        if (!marker) return;

        // Update marker icon if participation status changed
        const iconType = this.getMarkerTypeForLocation(location);
        marker.setIcon(this.getMarkerIcon(iconType));

        // Update title if needed
        marker.setTitle(location.title || location.name);
    },

    removeMarker(id) {
        if (this.markers[id]) {
            this.markers[id].setMap(null);
            delete this.markers[id];
        }
    },

    focusMarker({ id, lat, lng }) {
        this.map.setCenter({ lat: parseFloat(lat), lng: parseFloat(lng) });
        this.map.setZoom(15);

        // Highlight the marker
        const marker = this.markers[id];
        if (marker) {
            // Optionally animate or highlight the marker
            marker.setAnimation(google.maps.Animation.BOUNCE);
            setTimeout(() => marker.setAnimation(null), 1500);
        }
    },

    centerMap(data) {
        this.map.setCenter({
            lat: parseFloat(data.lat),
            lng: parseFloat(data.lng)
        });

        if (data.zoom) {
            this.map.setZoom(data.zoom);
        }
    },

    getUserLocation(data) {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    this.pushEvent("user-location-result", {
                        lat: position.coords.latitude.toString(),
                        lng: position.coords.longitude.toString(),
                        radius: data.radius
                    });
                },
                () => {
                    alert("Error: Unable to retrieve your location");
                }
            );
        } else {
            alert("Error: Your browser doesn't support geolocation");
        }
    },

    tryGetUserInitialLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const pos = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude,
                    };
                    this.map.setCenter(pos);

                    // Add a special marker for user's current location
                    this.userLocationMarker = new google.maps.Marker({
                        position: pos,
                        map: this.map,
                        icon: this.getMarkerIcon('user'),
                        title: "Your Location",
                    });
                },
                () => {
                    console.log("Error: The Geolocation service failed.");
                }
            );
        }
    },

    getMarkerTypeForLocation(location) {
        if (location.is_creator) return 'creator';
        if (location.is_participant) return 'participant';
        return 'default';
    },

    getMarkerIcon(type) {
        switch (type) {
            case 'creator':
                return {
                    path: google.maps.SymbolPath.STAR,
                    scale: 10,
                    fillColor: "#3B82F6", // Blue star for created events
                    fillOpacity: 0.8,
                    strokeWeight: 1,
                    strokeColor: "#FFFFFF",
                };

            case 'participant':
                return {
                    path: google.maps.SymbolPath.CIRCLE,
                    scale: 10,
                    fillColor: "#22C55E", // Green marker for participating
                    fillOpacity: 0.8,
                    strokeWeight: 1,
                    strokeColor: "#FFFFFF",
                };

            case 'selection':
                return {
                    path: google.maps.SymbolPath.CIRCLE,
                    scale: 8,
                    fillColor: "#FF5722", // Orange for selection
                    fillOpacity: 0.8,
                    strokeWeight: 1,
                    strokeColor: "#FFFFFF",
                };

            case 'user':
                return {
                    path: google.maps.SymbolPath.CIRCLE,
                    scale: 10,
                    fillColor: "#4285F4", // Google blue for user location
                    fillOpacity: 0.8,
                    strokeWeight: 1,
                    strokeColor: "#FFFFFF",
                };

            default:
                return null; // Default Google Maps marker
        }
    }
};

export default MeetupMap;