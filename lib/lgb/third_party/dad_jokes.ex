defmodule Lgb.ThirdParty.DadJokes do
  alias Lgb.ThirdParty.DadJokes.Fetch_Api

  def get_joke() do
    case Fetch_Api.get("/") do
      {:ok, http_response} ->
        {:ok, http_response.body}
      {:error, reason} -> {:error, reason.message}
    end
  end
end
