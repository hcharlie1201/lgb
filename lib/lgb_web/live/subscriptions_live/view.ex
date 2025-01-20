defmodule LgbWeb.SubscriptionsLive.View do
  alias Lgb.Accounts.User
  alias Lgb.Profiles
  alias Lgb.Profiles.Profile
  alias Lgb.Subscriptions
  require Logger
  use LgbWeb, :live_view

  def mount(_params, _session, socket) do
    subscription_plans =
      Subscriptions.list_subscrpition_plans()
      |> Enum.map(&Subscriptions.fetch_subscription_plan_metadata(&1))

    {:ok,
     socket
     |> assign(:user, nil)
     |> assign(:subscription_plans, subscription_plans)}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event(_event, _params, socket) do
    {:noreply, socket}
  end
end
