defmodule Lgb.ThirdParty.Stripe.Plans do
  use HTTPoison.Base
  @endpoint "https://api.stripe.com/v1/prices"

  def process_request_url(url) do
    @endpoint <> url
  end
end
