// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import { StripeAddress } from "./stripe/address";
import { StripeCheckout } from "./stripe/checkout";
import { ScrollBottom } from "./scroll_bottom";
import { Geolocation } from "./geolocation";
import { StarsBackground } from "./stars_background";
import MeetupMap from "./meetup_map";
import topbar from "../vendor/topbar";

let Hooks = {};
Hooks.Map = {
  mounted() {
    const sridString = this.el.dataset.geo;
    let match = sridString.match(/POINT\((-?\d+\.\d+) (-?\d+\.\d+)\)/);

    if (!match) {
      match = [0, 51, 0.1];
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
    let lastMarker = null;

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
  },
};
Hooks.StripeAddress = StripeAddress;
Hooks.StripeCheckout = StripeCheckout;
Hooks.ScrollBottom = ScrollBottom;
Hooks.Geolocation = Geolocation;
Hooks.StarsBackground = StarsBackground;
Hooks.MeetupMap = MeetupMap;

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// Posthog
window.addEventListener("phx:navigate", ({ detail: { href } }) => {
  posthog.capture("$pageview", {
    $current_url: href,
  });
});
// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
