import { Hook, makeHook } from "phoenix_typed_hook";
import L from "leaflet";

class DiscoverMap extends Hook {
    mounted() {
        const sridString = this.el.dataset.geo;
        let match = sridString?.match(/POINT\((-?\d+\.\d+) (-?\d+\.\d+)\)/);
        if (!match) {
            match = ["0", "51", "0.1"];
        }

        const [latitude, longitude] = [parseFloat(match[1]), parseFloat(match[2])];
        const map = L.map("mapid").setView([latitude, longitude], 10);

        // Add the OpenStreetMap tile layer
        L.tileLayer("https://tile.openstreetmap.org/{z}/{x}/{y}.png", {
            maxZoom: 19,
            attribution:
                '&copy; <a href="http://www.openstreetmap.org/copyright">OpenStreetMap</a>',
        }).addTo(map);

        const addCircle = (latlng, color = "blue") => {
            return L.circle(latlng, {
                color,
                fillColor: color === "blue" ? "#03f" : "#f03",
                fillOpacity: 0.5,
                radius: 10000,
            }).addTo(map);
        };

        let circle = addCircle([latitude, longitude], "red");
        let lastMarker: null | L.Marker<any> = null;

        // Add popup on map click
        map.on("click", (e) => {
            if (lastMarker) map.removeLayer(lastMarker);
            if (circle) map.removeLayer(circle);

            // Add a new circle and marker
            circle = addCircle(e.latlng);
            lastMarker = L.marker(e.latlng).addTo(map);

            // Show popup with coordinates
            L.popup()
                .setLatLng(e.latlng)
                .setContent(`Your approximate location: ${e.latlng.toString()}`)
                .openOn(map);

            // Push the coordinates back to the server
            this.pushEvent("map_clicked", { lat: e.latlng.lat, lng: e.latlng.lng });
        });
    }
};

export default makeHook(DiscoverMap);