defmodule LgbWeb.AccountLive.View do
  require Logger
  use LgbWeb, :live_view

  def mount(_params, _session, socket) do
    stripe_customer = Lgb.Accounts.get_stripe_customer(socket.assigns.current_user)

    {:ok, stripe_customer_metadata} = Lgb.ThirdParty.Stripe.fetch_stripe_customer(stripe_customer)

    socket = assign(socket, account_info: stripe_customer_metadata)
    {:ok, socket}
  end

  def handle_params(_params, _url, socket) do
    {:noreply, socket}
  end

  defp normalize_address(address) do
    [
      address["line1"],
      address["line2"],
      "#{address["city"]}, #{address["state"]} #{address["postal_code"]}",
      address["country"]
    ]
    # Remove empty fields
    |> Enum.reject(&(&1 == ""))
    |> Enum.join(", ")
  end
end
