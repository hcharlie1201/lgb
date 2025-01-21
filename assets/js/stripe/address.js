export const StripeAddress = {
  mounted() {
    const publishableKey = this.el.dataset.stripekey;
    const googleMapsKey = this.el.dataset.googlekey;
    const stripe = Stripe(publishableKey);

    const options = {
      // Fully customizable with appearance API.
      appearance: {
        theme: "flat",
        variables: { colorPrimaryText: "#262626" },
      },
    };

    const elements = stripe.elements(options);

    // Create and mount the Address Element in shipping mode
    const addressElement = elements.create("address", {
      mode: "billing",
      autocomplete: {
        mode: "google_maps_api",
        apiKey: googleMapsKey,
      },
    });
    addressElement.mount("#address-element");
    addressElement.on("change", (event) => {
      if (event.complete) {
        // Extract potentially complete address
        const address = event.value.address;
        const name = event.value.name;
        this.pushEvent("update_address", { address: address, name: name });
      }
    });
  },
};
