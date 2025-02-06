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

      socket =
        assign(socket, account_info: stripe_customer_metadata, portal_url: portal_metadata["url"])

      {:ok, socket}
    else
      {:ok, assign(socket, account_info: %{}, portal_url: nil)}
    end
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  def handle_event("manage_account", %{"url" => portal_url}, socket) do
    {:noreply, redirect(socket, external: portal_url)}
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
