defmodule Lgb.ThirdParty.Google.ReverseGeo do
  @moduledoc """
  A service for reverse geocoding using Google Maps API.
  """

  @doc """
  Takes a latitude and longitude and returns the address.
  """
  def get_address(latitude, longitude) do
    api_key = System.fetch_env!("GOOGLE_MAPS_API_KEY")

    url =
      "https://maps.googleapis.com/maps/api/geocode/json?latlng=#{latitude},#{longitude}&key=#{api_key}"

    response = HTTPoison.get!(url)

    %{"results" => [address | _]} = Poison.decode!(response.body)

    %{
      "address_components" => address_components
    } = address

    city =
      Enum.find(address_components, fn component -> "locality" in component["types"] end)[
        "long_name"
      ]

    state =
      Enum.find(address_components, fn component ->
        "administrative_area_level_1" in component["types"]
      end)["short_name"]

    zip =
      Enum.find(address_components, fn component -> "postal_code" in component["types"] end)[
        "short_name"
      ]

    [city: city, state: state, zip: zip]
  end
end
