defmodule Lgb.ProfilesTest do
  use Lgb.DataCase

  alias Lgb.Profiles
  import Lgb.ProfilesFixtures
  import Lgb.AccountsFixtures

  describe "profiles" do
    alias Lgb.Profiles.Profile

    @invalid_attrs %{age: 0}

    setup do
      user = user_fixture()
      %{user: user}
    end

    test "list_profiles/1 returns profiles with pagination metadata", %{user: user} do
      profile = profile_fixture(user)
      {:ok, %{entries: profiles}} = Profiles.list_profiles(%{})
      assert length(profiles) > 0
      assert profile in profiles
    end

    test "get_profile!/1 returns the profile with given id", %{user: user} do
      profile = profile_fixture(user)
      assert Profiles.get_profile!(profile.id) == profile
    end

    test "create_profile/2 with valid data creates a profile", %{user: user} do
      valid_attrs = %{
        handle: "some handle",
        state: "some state",
        zip: "some zip",
        age: 25,
        height_cm: 170,
        weight_lb: 150,
        city: "some city",
        biography: "some biography"
      }

      assert {:ok, %Profile{} = profile} = Profiles.create_profile(user, valid_attrs)
      assert profile.handle == "some handle"
      assert profile.state == "some state"
      assert profile.zip == "some zip"
      assert profile.height_cm == 170
      assert profile.weight_lb == 150
      assert profile.city == "some city"
      assert profile.biography == "some biography"
    end

    test "create_profile/2 with invalid data returns error changeset", %{user: user} do
      assert {:error, %Ecto.Changeset{}} = Profiles.create_profile(user, @invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile", %{user: user} do
      profile = profile_fixture(user)

      update_attrs = %{
        handle: "updated handle",
        state: "updated state",
        zip: "12345",
        height_cm: 175,
        weight_lb: 160,
        city: "updated city",
        biography: "updated biography"
      }

      assert {:ok, %Profile{} = profile} = Profiles.update_profile(profile, update_attrs)
      assert profile.handle == "updated handle"
      assert profile.state == "updated state"
      assert profile.zip == "12345"
      assert profile.height_cm == 175
      assert profile.weight_lb == 160
      assert profile.city == "updated city"
      assert profile.biography == "updated biography"
    end

    test "update_profile/2 with invalid data returns error changeset", %{user: user} do
      profile = profile_fixture(user)
      assert {:error, %Ecto.Changeset{}} = Profiles.update_profile(profile, @invalid_attrs)
      assert profile == Profiles.get_profile!(profile.id)
    end

    test "delete_profile/1 deletes the profile", %{user: user} do
      profile = profile_fixture(user)
      assert {:ok, %Profile{}} = Profiles.delete_profile(profile)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_profile!(profile.id) end
    end

    test "change_profile/1 returns a profile changeset", %{user: user} do
      profile = profile_fixture(user)
      assert %Ecto.Changeset{} = Profiles.change_profile(profile)
    end
  end

  describe "profile options" do
    test "generate_height_options/0 returns list of height options" do
      options = Profiles.generate_height_options()
      assert length(options) > 0

      assert Enum.all?(options, fn {label, value} ->
               is_binary(label) and is_integer(value)
             end)

      # Test a specific value
      assert {"5 ft 8 in", 173} in options
    end

    test "generate_weight_options/0 returns list of weight options" do
      options = Profiles.generate_weight_options()
      # 100 to 300 lbs
      assert length(options) == 201

      assert Enum.all?(options, fn {label, value} ->
               is_binary(label) and is_integer(value)
             end)

      # Test a specific value
      assert {"150 lbs", 150} in options
    end
  end

  describe "profile search" do
    setup do
      user = user_fixture()

      profile =
        profile_fixture(user, %{
          height_cm: 170,
          weight_lb: 150,
          age: 25
        })

      %{profile: profile}
    end

    test "create_filter/1 creates search filters with all parameters" do
      params = %{
        "min_height_cm" => "165",
        "max_height_cm" => "175",
        "min_age" => "20",
        "max_age" => "30",
        "min_weight" => "140",
        "max_weight" => "160"
      }

      filters = Profiles.create_filter(params)

      # Test all filter combinations
      expected_filters = [
        %{field: :height_cm, op: :>=, value: 165},
        %{field: :height_cm, op: :<=, value: 175},
        %{field: :age, op: :>=, value: 20},
        %{field: :age, op: :<=, value: 30},
        %{field: :weight_lb, op: :>=, value: 140},
        %{field: :weight_lb, op: :<=, value: 160}
      ]

      assert length(filters) == length(expected_filters)

      Enum.each(expected_filters, fn expected ->
        assert Enum.any?(filters, fn filter ->
                 filter.field == expected.field and
                   filter.op == expected.op and
                   filter.value == expected.value
               end)
      end)
    end

    test "create_filter/1 handles empty parameters" do
      params = %{"min_height_cm" => "", "max_age" => nil}
      filters = Profiles.create_filter(params)
      assert filters == []
    end

    test "get_other_profiles_distance/1 returns query with distance calculation when geolocation present",
         %{profile: profile} do
      # Add a geolocation point to the profile
      {:ok, updated_profile} =
        Profiles.update_profile(profile, %{
          geolocation: %Geo.Point{coordinates: {-122.27652, 37.80574}, srid: 4326}
        })

      query = Profiles.get_other_profiles_distance(updated_profile)

      assert query.__struct__ == Ecto.Query
      # Verify the query includes distance calculation in select_merge
      assert %{expr: {:merge, _, [_, {:%{}, _, [{:distance, _}]}]}} = query.select
    end

    test "get_other_profiles_distance/1 returns basic query without distance when no geolocation",
         %{profile: profile} do
      query = Profiles.get_other_profiles_distance(profile)
      assert query.__struct__ == Ecto.Query
      # Verify no distance calculation is included
      refute query.select
    end
  end
end
