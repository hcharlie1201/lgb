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
import { HooksOptions, LiveSocket } from "phoenix_live_view";
import StripeCheckout from "./stripe/checkout.js";
import ScrollBottom from "./scroll_bottom.js";
import Geolocation from "./geolocation.js";
import StarsBackground from "./stars_background.js";
import StripeAddress from "./stripe/address.js";
import DiscoverMap from "./discover_map.js";
import MeetupMap from "./meetup_map/index.js";
import topbar from "../vendor/topbar.js";
import posthog from "posthog-js"


const Hooks: HooksOptions = {
  Map: DiscoverMap,
  StripeAddress: StripeAddress,
  StripeCheckout: StripeCheckout,
  ScrollBottom: ScrollBottom,
  Geolocation: Geolocation,
  StarsBackground: StarsBackground,
  MeetupMap: MeetupMap,
};

declare global {
  interface WindowEventMap {
    "phx:navigate": CustomEvent<{ href: string }>;
  }
}

let csrfToken = document
  .querySelector("meta[name='csrf-token']")!.getAttribute("content");
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
// Define the type for the custom event
type PhxNavigateEvent = CustomEvent<{ href: string }>;

// Add the event listener with type annotations
window.addEventListener("phx:navigate", (event: PhxNavigateEvent) => {
  const { href } = event.detail;

  // Capture the pageview event with PostHog
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
