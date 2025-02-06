export const StripeCheckout = {
  mounted() {
    const stripe = Stripe(this.el.dataset.stripekey);
    const options = {
      clientSecret: this.el.dataset.clientsecret,
      // Fully customizable with appearance API.
      appearance: {
        theme: "stripe",
      },
    };

    // Set up Stripe.js and Elements to use in checkout form, passing the client secret obtained in step 5
    const elements = stripe.elements(options);

    const paymentElementOptions = {
      layout: "tabs",
    };

    // Create and mount the Payment Element
    const paymentElement = elements.create("payment", paymentElementOptions);
    paymentElement.mount("#payment-element");

    const form = document.getElementById("stripe-checkout-form");

    form.addEventListener("submit", async (event) => {
      event.preventDefault();

      const { error, paymentIntent } = await stripe.confirmPayment({
        //`Elements` instance that was used to create the Payment Element
        elements,
        redirect: "if_required",
      });

      if (error) {
        // This point will only be reached if there is an immediate error when
        // confirming the payment. Show error to your customer (for example, payment
        // details incomplete)
        const messageContainer = document.querySelector("#error-message");
        messageContainer.textContent = error.message;
      } else {
        // Your customer will be redirected to your `return_url`. For some payment
        // methods like iDEAL, your customer will be redirected to an intermediate
        // site first to authorize the payment, then redirected to the `return_url`.
        this.pushEvent("payment_success", paymentIntent);
      }
    });
  },
};
