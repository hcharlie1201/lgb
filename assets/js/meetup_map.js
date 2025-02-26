const MeetupMap = {
    mounted() {
        this.markers = [];
        this.infoWindows = [];

        // Load Google Maps
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

        // Listen for events to focus on a marker
        window.addEventListener("focus-map-marker", (e) => {
            const { lat, lng } = e.detail;
            this.map.setCenter({ lat, lng });
            this.map.setZoom(15);

            // Find and open the info window
            const index = this.markers.findIndex(marker =>
                marker.getPosition().lat() === parseFloat(lat) && marker.getPosition().lng() === parseFloat(lng)
            );

            if (index !== -1 && this.infoWindows[index]) {
                this.infoWindows[index].open(this.map, this.markers[index]);
            }
        });

        // Listen for location updates from server
        this.handleEvent("update-locations", (data) => {
            this.updateMarkers(data.locations);
        });

        // Listen for map centering
        this.handleEvent("center-map", (data) => {
            this.map.setCenter({ lat: parseFloat(data.lat), lng: parseFloat(data.lng) });
            if (data.zoom) {
                this.map.setZoom(data.zoom);
            }
        });

        // Listen for geolocation requests
        this.handleEvent("get-user-location", (data) => {
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
        });
    },

    initMap() {
        // Default map center (San Francisco)
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
            const position = event.latLng;
            this.handleMapClick(position);
        });

        // Add bounds_changed listener to load locations in view
        this.map.addListener("bounds_changed", () => {
            this.handleBoundsChanged();
        });

        // Try to get user's current location
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const pos = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude,
                    };
                    this.map.setCenter(pos);

                    // Add a special marker for user's current location
                    new google.maps.Marker({
                        position: pos,
                        map: this.map,
                        icon: {
                            path: google.maps.SymbolPath.CIRCLE,
                            scale: 10,
                            fillColor: "#4285F4",
                            fillOpacity: 0.8,
                            strokeWeight: 1,
                            strokeColor: "#FFFFFF",
                        },
                        title: "Your Location",
                    });
                },
                () => {
                    console.log("Error: The Geolocation service failed.");
                }
            );
        }
    },

    handleBoundsChanged() {
        // Don't send too many events - debounce
        if (this.boundsChangeTimeout) {
            clearTimeout(this.boundsChangeTimeout);
        }

        this.boundsChangeTimeout = setTimeout(() => {
            const bounds = this.map.getBounds();
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
            position: position,
            map: this.map,
            animation: google.maps.Animation.DROP,
            icon: {
                path: google.maps.SymbolPath.CIRCLE,
                scale: 8,
                fillColor: "#FF5722",
                fillOpacity: 0.8,
                strokeWeight: 1,
                strokeColor: "#FFFFFF",
            },
        });
    },

    updateMarkers(locations) {
        // Clear existing markers
        this.markers.forEach(marker => marker.setMap(null));
        this.markers = [];
        this.infoWindows = [];

        // Add markers for each location
        locations.forEach(location => {
            const position = new google.maps.LatLng(
                parseFloat(location.latitude),
                parseFloat(location.longitude)
            );

            // Customize marker based on participation status
            let markerOptions = {
                position: position,
                map: this.map,
                title: location.title || location.name,
            };

            // If user is participating, use a different marker color
            if (location.is_participant) {
                markerOptions.icon = {
                    path: google.maps.SymbolPath.CIRCLE,
                    scale: 10,
                    fillColor: "#22C55E", // Green marker for participating
                    fillOpacity: 0.8,
                    strokeWeight: 1,
                    strokeColor: "#FFFFFF",
                };
            }

            // If user is the creator, use a star icon
            if (location.is_creator) {
                markerOptions.icon = {
                    path: google.maps.SymbolPath.STAR,
                    scale: 10,
                    fillColor: "#3B82F6", // Blue star for created events
                    fillOpacity: 0.8,
                    strokeWeight: 1,
                    strokeColor: "#FFFFFF",
                };
            }

            const marker = new google.maps.Marker(markerOptions);

            // Send the location ID to the server on click
            marker.addListener("click", () => {
                this.pushEvent("open-location-modal", {
                    location_id: location.id
                });
            });

            this.markers.push(marker);
        });
    }
};

export default MeetupMap;