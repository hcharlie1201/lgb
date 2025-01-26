defmodule LgbWeb.ShoppingLive.SubscriptionsLive.Checkout do
  alias Lgb.Subscriptions
  alias Lgb.Billing
  require Logger
  use LgbWeb, :live_view

  def mount(params, _session, socket) do
    with {:ok, subscription_plan} <- fetch_subscription_plan(params),
         {:ok, stripe_customer} <- fetch_stripe_customer(socket, params),
         {:ok, stripe_subscription} <-
           process_subscription(stripe_customer, subscription_plan),
         {:ok, metadata} <-
           Lgb.Billing.StripeSubscription.get_metadata(stripe_subscription) do
      {:ok, payment_intent} =
        Lgb.Billing.StripeSubscription.get_payment_intent_from_metadata(metadata)

      if payment_intent["status"] == "succeeded" || payment_intent["status"] == "processing" do
        {:ok,
         push_navigate(socket,
           to: ~p"/shopping/subscriptions/confirmed/payment/#{payment_intent["id"]}"
         )}
      else
        socket =
          socket
          |> assign(
            client_secret: payment_intent["client_secret"],
            stripe_key: System.fetch_env!("STRIPE_API_PUBLISHABLE_KEY_TEST"),
            stripe_subscription: stripe_subscription
          )

        {:ok, socket}
      end
    else
      {:redirect, socket} -> {:ok, socket}
      {:error, error_message} -> {:ok, put_flash(socket, :error, error_message)}
    end
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("payment_success", params, socket) do
    IO.inspect(params)
    # update subscription
    body = %{
      "metadata[initial_checkout_completed]" => "true"
    }

    inspect(
      Lgb.ThirdParty.Stripe.update_stripe_subscription!(socket.assigns.stripe_subscription, body)
    )

    {:noreply,
     push_navigate(socket, to: ~p"/shopping/subscriptions/confirmed/payment/#{params["id"]}")}
  end

  def handle_event("update_address", params, socket) do
    new_form = Map.merge(socket.assigns.form, params)
    socket = assign(socket, form: new_form)
    {:noreply, socket}
  end

  defp fetch_subscription_plan(params) do
    {:ok, Subscriptions.get_subscription_plan!(params["id"])}
  rescue
    _ -> {:error, "Invalid subscription plan"}
  end

  defp fetch_stripe_customer(socket, params) do
    case Lgb.Accounts.get_stripe_customer(socket.assigns.current_user) do
      nil ->
        {:redirect, push_navigate(socket, to: ~p"/shopping/subscriptions/#{params["id"]}/info")}

      customer ->
        {:ok, customer}
    end
  end

  defp process_subscription(stripe_customer, subscription_plan) do
    case Billing.current_stripe_subscription(stripe_customer) do
      nil -> create_new_subscription(stripe_customer, subscription_plan)
      existing_subscription -> {:ok, existing_subscription}
    end
  end

  defp create_new_subscription(stripe_customer, subscription_plan) do
    case Billing.create_stripe_subscription(stripe_customer, subscription_plan) do
      {:ok, stripe_subscription} -> {:ok, stripe_subscription}
      {:error, error_message} -> {:error, error_message}
    end
  end
end
