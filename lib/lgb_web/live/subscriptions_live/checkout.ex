defmodule LgbWeb.SubscriptionsLive.Checkout do
  alias Lgb.Accounts.User
  alias Lgb.Profiles
  alias Lgb.Profiles.Profile
  alias Lgb.Subscriptions
  alias Lgb.Billing
  require Logger
  use LgbWeb, :live_view

  def mount(params, _session, socket) do
    with {:ok, subscription_plan} <- fetch_subscription_plan(params),
         {:ok, stripe_customer} <- fetch_stripe_customer(socket, params),
         {:ok, socket} <- process_subscription(stripe_customer, subscription_plan, socket) do
      {:ok, socket}
    else
      {:redirect, socket} -> {:ok, socket}
      {:error, error_message} -> {:ok, put_flash(socket, :error, error_message)}
    end
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

  defp fetch_subscription_plan(params) do
    {:ok, Subscriptions.get_subscription_plan!(params["id"])}
  rescue
    _ -> {:error, "Invalid subscription plan"}
  end

  defp fetch_stripe_customer(socket, params) do
    case Lgb.Accounts.get_stripe_customer(socket.assigns.current_user) do
      nil -> {:redirect, push_navigate(socket, to: ~p"/subscriptions/#{params["id"]}/info")}
      customer -> {:ok, customer}
    end
  end

  defp process_subscription(stripe_customer, subscription_plan, socket) do
    case Billing.current_stripe_subscription(stripe_customer) do
      nil -> create_new_subscription(stripe_customer, subscription_plan, socket)
      _existing_subscription -> {:ok, socket}
    end
  end

  defp create_new_subscription(stripe_customer, subscription_plan, socket) do
    case Billing.create_stripe_subscription(stripe_customer, subscription_plan) do
      {:ok, _stripe_subscription} -> {:ok, socket}
      {:error, error_message} -> {:error, error_message}
    end
  end
end
