defmodule Lgb.ThirdParty.Google.ReverseGeoTest do
  use ExUnit.Case, async: true
  alias Lgb.ThirdParty.Google.ReverseGeo

  describe "get_address/2" do
    test "returns address components for valid coordinates" do
      lat = 37.4224764
      lng = -122.0842499

      assert [city: city, state: state, zip: zip] = ReverseGeo.get_address(lat, lng)
      assert is_binary(city)
      assert is_binary(state)
      assert is_binary(zip)
    end

    test "handles invalid coordinates gracefully" do
      lat = 999.0
      lng = 999.0

      assert [] = ReverseGeo.get_address(lat, lng)
    end
  end
end
