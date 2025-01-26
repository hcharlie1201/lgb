defmodule LgbWeb.ShoppingLive.SubscriptionsLive.View do
  alias Lgb.Subscriptions
  require Logger
  use LgbWeb, :live_view

  def mount(_params, _session, socket) do
    subscription_plans =
      Subscriptions.list_subscription_plans()
      |> Enum.map(&Subscriptions.fetch_subscription_plan_metadata(&1))

    stripe_customer = Lgb.Accounts.get_stripe_customer(socket.assigns.current_user)

    stripe_subscription =
      if stripe_customer do
        Lgb.Billing.current_stripe_subscription(stripe_customer)
      else
        nil
      end

    completed_initial_checkout =
      stripe_subscription && Lgb.Billing.initial_checkout_completed?(stripe_subscription)

    {:ok,
     socket
     |> assign(:user, nil)
     |> assign(:subscription_plans, subscription_plans)
     |> assign(:completed_initial_checkout, completed_initial_checkout)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end

  defp format_money(nil), do: "0.00"
  defp format_money(amount_cents) do
    amount_cents
    |> Decimal.new()
    |> Decimal.div(100)
    |> Decimal.to_string()
  end
end
