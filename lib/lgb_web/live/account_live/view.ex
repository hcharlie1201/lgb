defmodule LgbWeb.AccountLive.View do
  require Logger
  use LgbWeb, :live_view

  def mount(_params, _session, socket) do
    stripe_customer = Lgb.Accounts.get_stripe_customer(socket.assigns.current_user)

    if stripe_customer do
      {:ok, stripe_customer_metadata} =
        Lgb.ThirdParty.Stripe.fetch_stripe_customer(stripe_customer)

      params = %{
        "customer" => stripe_customer.customer_id
      }

      {:ok, portal_metadata} = Lgb.ThirdParty.Stripe.create_stripe_session(params)
      {:ok, subscription_object} = get_stripe_subscription_status(stripe_customer)
      IO.puts("wtf")

      socket =
        assign(socket,
          account_info: stripe_customer_metadata,
          portal_url: portal_metadata["url"],
          status: subscription_object["status"]
        )

      {:ok, socket}
    else
      {:ok, assign(socket, account_info: %{}, portal_url: nil, status: nil)}
    end
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("manage_account", %{"url" => portal_url}, socket) do
    {:noreply, redirect(socket, external: portal_url)}
  end

  defp get_stripe_subscription_status(stripe_customer) do
    stripe_subscription =
      Lgb.Billing.current_stripe_subscription(stripe_customer)

    with {:ok, subscription_object} <-
           Lgb.ThirdParty.Stripe.fetch_stripe_subscription(stripe_subscription) do
      {:ok, subscription_object}
    else
      {:error, message} -> {:error, message}
    end
  end

  defp normalize_address(address) do
    if address != nil do
      [
        address["line1"],
        address["line2"],
        "#{address["city"]}, #{address["state"]} #{address["postal_code"]}",
        address["country"]
      ]
      # Remove empty fields
      |> Enum.reject(&(&1 == ""))
      |> Enum.join(", ")
    else
      ""
    end
  end
end
