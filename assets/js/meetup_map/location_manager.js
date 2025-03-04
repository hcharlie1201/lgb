class LocationManager {
    constructor(hook) {
        this.hook = hook;
        this.userLocationMarker = null;
        this.userAccuracyCircle = null;
    }

    setMap(map) {
        this.map = map;
    }

    getUserLocation(data) {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    this.hook.pushEvent("user-location-result", {
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
    }

    tryGetUserInitialLocation() {
        if (navigator.geolocation) {
            navigator.geolocation.getCurrentPosition(
                (position) => {
                    const pos = {
                        lat: position.coords.latitude,
                        lng: position.coords.longitude,
                    };
                    this.map.setCenter(pos);

                    // Remove previous markers if they exist
                    if (this.userLocationMarker) {
                        this.userLocationMarker.map = null;
                    }

                    // Create a dot element for user location
                    const dot = document.createElement('div');
                    dot.style.width = '24px';
                    dot.style.height = '24px';
                    dot.style.borderRadius = '50%';
                    dot.style.backgroundColor = '#4285F4'; // Google blue
                    dot.style.border = '3px solid white';
                    dot.style.boxShadow = '0 0 8px rgba(0, 0, 0, 0.3)';

                    // Add a special marker for user's current location
                    this.userLocationMarker = new google.maps.marker.AdvancedMarkerElement({
                        position: pos,
                        map: this.map,
                        title: "Your Location",
                        content: dot
                    });

                    // Add accuracy circle if needed
                    if (position.coords.accuracy) {
                        this.addAccuracyCircle(pos, position.coords.accuracy);
                    }
                },
                () => {
                    console.log("Error: The Geolocation service failed.");
                }
            );
        }
    }

    addAccuracyCircle(position, accuracy) {
        // Remove previous circle if it exists
        if (this.userAccuracyCircle) {
            this.userAccuracyCircle.setMap(null);
        }

        this.userAccuracyCircle = new google.maps.Circle({
            map: this.map,
            center: position,
            radius: accuracy,
            fillColor: '#4285F4',
            fillOpacity: 0.15,
            strokeColor: '#4285F4',
            strokeOpacity: 0.3,
            strokeWeight: 1
        });
    }
}

export default LocationManager;