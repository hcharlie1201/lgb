import { Hook, makeHook } from "phoenix_typed_hook";
import Stripe from "stripe";

class StripeAddress extends Hook {
  mounted() {
    const publishableKey = this.el.dataset.stripekey;
    const googleMapsKey = this.el.dataset.googlekey;
    const stripe = Stripe(publishableKey);
    const options = {
      appearance: {
        theme: "flat",
        variables: {
          colorPrimary: '#9333EA', // Purple-600
          colorPrimaryText: '#9333EA',
          colorText: '#4B5563', // Gray-600
          colorTextSecondary: '#6B7280', // Gray-500
          colorBackground: '#FFFFFF',
          colorBackgroundText: '#1F2937', // Gray-800
          spacingGridRow: '1rem',
        },
        rules: {
          '.Input': {
            borderColor: '#E5E7EB', // Gray-200
            boxShadow: '0 1px 2px 0 rgb(0 0 0 / 0.05)',
          },
          '.Input:hover': {
            borderColor: '#9333EA', // Purple-600
          },
          '.Input:focus': {
            borderColor: '#9333EA',
            boxShadow: '0 0 0 1px #9333EA',
          },
          '.Label': {
            color: '#4B5563', // Gray-600
          },
          '.Tab': {
            borderColor: '#9333EA',
            color: '#9333EA',
          },
          '.Tab:hover': {
            color: '#7E22CE', // Purple-700
          },
          '.Tab--selected': {
            backgroundColor: '#9333EA',
            color: 'white',
          }
        }
      }
    };
    const elements = stripe.elements(options);
    const form = document.getElementById("stripe-address-form");

    const addressElement = elements.create("address", {
      mode: "billing",
      autocomplete: {
        mode: "google_maps_api",
        apiKey: googleMapsKey,
      },
    });
    addressElement.mount("#address-element");


    form.addEventListener("submit", async (event) => {
      event.preventDefault();

      try {
        const result = await addressElement.getValue();
        if (result.complete) {
          this.pushEvent("info_success", result.value);
        }
      } catch (error) {
        this.pushEvent("address_error", { message: error.message });
      }
    });
  }
}

export default makeHook(StripeAddress);
