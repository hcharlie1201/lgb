defmodule LgbWeb.ShoppingLive.SubscriptionsLive.Confirmed do
  use LgbWeb, :live_view
  require Logger

  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(%{"id" => payment_intent_id}, _url, socket) do
    with {:ok, payment_intent} <- Lgb.ThirdParty.Stripe.fetch_payment_intent(payment_intent_id),
         {:ok, charge_object} <-
           Lgb.ThirdParty.Stripe.get_stripe_charge(payment_intent["latest_charge"]) do
      {:noreply, assign(socket, receipt_url: charge_object["receipt_url"])}
    else
      {:error, message} ->
        socket = socket |> put_flash(:error, message)
        {:noreply, socket}
    end
  end
end
