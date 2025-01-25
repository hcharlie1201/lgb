defmodule LgbWeb.ShoppingLive.SubscriptionsLive.Confirmed do
  alias Lgb.Accounts.User
  alias Lgb.Profiles
  alias Lgb.Profiles.Profile
  alias Lgb.Subscriptions
  alias Lgb.Billing
  require Logger
  use LgbWeb, :live_view

  def mount(params, _session, socket) do
    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end
end
