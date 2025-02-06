defmodule LgbWeb.ShoppingLive.SubscriptionsLive.Info do
  require Logger
  use LgbWeb, :live_view

  def mount(params, _session, socket) do
    # if user has subscription then bring them to dashboard
    # if user has a stripe account then bring them to checkout
    customer = Lgb.Accounts.get_stripe_customer(socket.assigns.current_user)

    stripe_subscription =
      if customer do
        Lgb.Billing.get_stripe_subscription(customer)
      else
        nil
      end

    cond do
      customer &&
        stripe_subscription && Lgb.Billing.initial_checkout_completed?(stripe_subscription) ->
        {:ok, push_navigate(socket, to: ~p"/account")}

      customer ->
        {:ok, push_navigate(socket, to: ~p"/shopping/subscriptions/#{params["id"]}/checkout")}

      true ->
        socket = assign(socket, form: %{})
        socket = assign(socket, subscription_plan_id: params["id"])
        socket = assign(socket, stripe_key: System.fetch_env!("STRIPE_API_PUBLISHABLE_KEY_TEST"))
        socket = assign(socket, google_key: System.fetch_env!("GOOGLE_MAPS_API_KEY"))

        {:ok, socket}
    end
  end

  def handle_event("info_success", params, socket) do
    case Lgb.Billing.create_stripe_customer(socket.assigns.current_user, params) do
      {:ok, _stripe_customer} ->
        {:noreply,
         push_navigate(socket,
           to: ~p"/shopping/subscriptions/#{socket.assigns.subscription_plan_id}/checkout"
         )}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, reason)}
    end
  end
end
