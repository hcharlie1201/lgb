defmodule Lgb.ThirdParty.DadJokes.Fetch_Api do
  use HTTPoison.Base
  @endpoint "https://icanhazdadjoke.com/"

  def process_request_url(url) do
    @endpoint <> url
  end

  def process_request_headers(headers) do
    [
      {"Accept", "text/plain"}
      | headers
    ]
  end
end
