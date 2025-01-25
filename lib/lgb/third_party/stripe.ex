defmodule Lgb.ThirdParty.Stripe do
  alias Lgb.ThirdParty.Stripe.Customers

  @doc """

  reponse
  {
    "id": "cus_NffrFeUfNV2Hib",
    "object": "customer",
    "address": null,
    "balance": 0,
    "created": 1680893993,
    "currency": null,
    "default_source": null,
    "delinquent": false,
    "description": null,
    "discount": null,
    "email": "jennyrosen@example.com",
    "invoice_prefix": "0759376C",
    "invoice_settings": {
      "custom_fields": null,
      "default_payment_method": null,
      "footer": null,
      "rendering_options": null
    },
    "livemode": false,
    "metadata": {},
    "name": "Jenny Rosen",
    "next_invoice_sequence": 1,
    "phone": null,
    "preferred_locales": [],
    "shipping": null,
    "tax_exempt": "none",
    "test_clock": null
  }
  """
  def fetch_stripe_customer(stripe_customer) do
    case Customers.get("/#{stripe_customer.customer_id}") do
      {:ok, http_response} ->
        {:ok, Poison.decode!(http_response.body)}

      {:error, whatever} ->
        {:error, whatever.message}
    end
  end

  def create_stripe_customer(body) do
    encoded_body = URI.encode_query(body)

    case Lgb.ThirdParty.Stripe.Customers.post("", encoded_body) do
      {:ok, http_response} ->
        {:ok, Poison.decode!(http_response.body)}

      {:error, reason} ->
        {:error, reason.message}
    end
  end

  def create_stripe_subscription(body) do
    encoded_body = URI.encode_query(body)

    case Lgb.ThirdParty.Stripe.Subscriptions.post("", encoded_body) do
      {:ok, http_response} -> {:ok, Poison.decode!(http_response.body)}
      {:error, reason} -> {:error, reason.message}
    end
  end
end
