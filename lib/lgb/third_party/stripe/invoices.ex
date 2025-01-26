defmodule Lgb.ThirdParty.Stripe.Invoices do
  use HTTPoison.Base
  @endpoint "https://api.stripe.com/v1/invoices"

  def process_request_url(url) do
    @endpoint <> url
  end

  def process_request_headers(headers) do
    api_key = System.fetch_env!("STRIPE_API_KEY_TEST")

    [
      {"Authorization", "Basic " <> Base.encode64("#{api_key}:")},
      {"Content-Type", "application/x-www-form-urlencoded"}
      | headers
    ]
  end
end
