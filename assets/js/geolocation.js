export const Geolocation = {
  mounted() {
    // Request geolocation immediately when the component mounts
    this.requestGeolocation();

    // Set up event handling for manual requests too
    this.handleEvent("request-geolocation", () => {
      this.requestGeolocation();
    });
  },

  requestGeolocation() {
    if (navigator.geolocation) {
      navigator.geolocation.getCurrentPosition(
        (position) => {
          this.pushEventTo(this.el, "geolocation-success", {
            latitude: position.coords.latitude,
            longitude: position.coords.longitude,
            accuracy: position.coords.accuracy,
          });
        },
        (error) => {
          this.pushEventTo(this.el, "geolocation-error", {
            message: error.message,
            code: error.code,
          });
        },
        {
          enableHighAccuracy: true,
          timeout: 5000,
          maximumAge: 0,
        },
      );
    } else {
      this.pushEvent("geolocation-error", {
        message: "Geolocation is not supported by this browser.",
        code: 0,
      });
    }
  },
};
