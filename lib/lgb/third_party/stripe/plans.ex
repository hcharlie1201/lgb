defmodule Lgb.ThirdParty.Stripe.Plans do
  use HTTPoison.Base
  @endpoint "https://api.stripe.com/v1/prices"

  def process_request_url(url) do
    @endpoint <> url
  end

  def process_request_headers(headers) do
    api_key = System.fetch_env!("STRIPE_API_KEY_TEST")

    [
      {"Authorization", "Basic " <> Base.encode64("#{api_key}:")}
      | headers
    ]
  end
end
