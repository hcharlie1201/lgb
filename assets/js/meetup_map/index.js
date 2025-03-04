import MarkerManager from './marker_manager.js';
import LocationManager from './location_manager.js';
import MapEvents from './map_events.js';

export const MeetupMap = {
    async mounted() {
        // Initialize managers
        this.markerManager = new MarkerManager(this);
        this.locationManager = new LocationManager(this);
        this.mapEvents = new MapEvents(this);

        // Load Google Maps
        await this.loadGoogleMaps();

        // Set up mutation observer for location streams
        this.setupLocationObserver();
    },

    loadGoogleMaps() {
        const apiKey = this.el.dataset.apiKey;

        // Return a Promise that resolves when Google Maps is loaded
        return new Promise((resolve) => {
            if (window.google && window.google.maps) {
                // If Maps is already loaded, initialize and resolve immediately
                this.initMap();
                resolve();
            } else {
                // Create script element for Maps API
                const script = document.createElement('script');
                script.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&callback=initGoogleMaps&v=weekly&libraries=marker&loading=async`;
                script.async = true;

                // Setup callback function
                window.initGoogleMaps = () => {
                    this.initMap();
                    resolve(); // Resolve the promise after initialization
                };

                document.head.appendChild(script);
            }
        });
    },

    initMap() {
        // Default map center
        const defaultCenter = { lat: 37.7749, lng: -122.4194 };

        this.map = new google.maps.Map(this.el, {
            zoom: 12,
            center: defaultCenter,
            mapId: "5c21f5c01da8345d", // https://console.cloud.google.com/google/maps-apis/studio/maps/5c21f5c01da8345d?project=bibi-451006
        });

        // Initialize managers with map
        this.markerManager.setMap(this.map);
        this.locationManager.setMap(this.map);
        this.mapEvents.setMap(this.map);

        // Set up event listeners
        this.mapEvents.setupEventListeners();

        // Try to get user's current location
        this.locationManager.tryGetUserInitialLocation();
    },

    setupLocationObserver() {
        const locationContainer = document.getElementById('location-markers');
        if (!locationContainer) return;

        const observer = new MutationObserver(() => {
            this.markerManager.syncMarkersFromDOM();
        });

        observer.observe(locationContainer, { childList: true, subtree: true });

        // Initial sync
        this.markerManager.syncMarkersFromDOM();
    },

    // Event handler methods that delegate to the appropriate manager
    handleMapClick(position) {
        this.mapEvents.handleMapClick(position);
    },

    handleBoundsChanged() {
        this.mapEvents.handleBoundsChanged();
    },

    focusMarker(details) {
        this.markerManager.focusMarker(details);
    },

    centerMap(data) {
        this.mapEvents.centerMap(data);
    },

    getUserLocation(data) {
        this.locationManager.getUserLocation(data);
    },
};
