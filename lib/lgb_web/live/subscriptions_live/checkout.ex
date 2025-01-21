defmodule LgbWeb.SubscriptionsLive.Checkout do
  alias Lgb.Accounts.User
  alias Lgb.Profiles
  alias Lgb.Profiles.Profile
  alias Lgb.Subscriptions
  require Logger
  use LgbWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, form: %{})
    socket = assign(socket, stripe_key: System.fetch_env!("STRIPE_API_PUBLISHABLE_KEY_TEST"))
    socket = assign(socket, google_key: System.fetch_env!("GOOGLE_MAPS_API_KEY"))

    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("submit", _params, socket) do
    IO.inspect(socket.assigns.form)

    case Lgb.Billing.create_stripe_customer(socket.assigns.current_user, socket.assigns.form) do
      {:ok, _stripe_customer} ->
        {:noreply, assign(socket, form: %{})}

      {:error, reason} ->
        {:noreply,
         socket
         |> put_flash(:error, reason)}
    end

    socket = assign(socket, form: %{})
    {:noreply, socket}
  end

  def handle_event("update_address", params, socket) do
    new_form = Map.merge(socket.assigns.form, params)
    socket = assign(socket, form: new_form)
    {:noreply, socket}
  end
end
