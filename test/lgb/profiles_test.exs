defmodule Lgb.ProfilesTest do
  use Lgb.DataCase

  alias Lgb.Profiles

  describe "profiles" do
    alias Lgb.Profiles.Profile

    import Lgb.ProfilesFixtures

    @invalid_attrs %{handle: nil, state: nil, zip: nil, dob: nil, height_cm: nil, weight_lb: nil, city: nil, biography: nil}

    test "list_profiles/0 returns all profiles" do
      profile = profile_fixture()
      assert Profiles.list_profiles() == [profile]
    end

    test "get_profile!/1 returns the profile with given id" do
      profile = profile_fixture()
      assert Profiles.get_profile!(profile.id) == profile
    end

    test "create_profile/1 with valid data creates a profile" do
      valid_attrs = %{handle: "some handle", state: "some state", zip: "some zip", dob: ~D[2024-12-11], height_cm: 42, weight_lb: 42, city: "some city", biography: "some biography"}

      assert {:ok, %Profile{} = profile} = Profiles.create_profile(valid_attrs)
      assert profile.handle == "some handle"
      assert profile.state == "some state"
      assert profile.zip == "some zip"
      assert profile.dob == ~D[2024-12-11]
      assert profile.height_cm == 42
      assert profile.weight_lb == 42
      assert profile.city == "some city"
      assert profile.biography == "some biography"
    end

    test "create_profile/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Profiles.create_profile(@invalid_attrs)
    end

    test "update_profile/2 with valid data updates the profile" do
      profile = profile_fixture()
      update_attrs = %{handle: "some updated handle", state: "some updated state", zip: "some updated zip", dob: ~D[2024-12-12], height_cm: 43, weight_lb: 43, city: "some updated city", biography: "some updated biography"}

      assert {:ok, %Profile{} = profile} = Profiles.update_profile(profile, update_attrs)
      assert profile.handle == "some updated handle"
      assert profile.state == "some updated state"
      assert profile.zip == "some updated zip"
      assert profile.dob == ~D[2024-12-12]
      assert profile.height_cm == 43
      assert profile.weight_lb == 43
      assert profile.city == "some updated city"
      assert profile.biography == "some updated biography"
    end

    test "update_profile/2 with invalid data returns error changeset" do
      profile = profile_fixture()
      assert {:error, %Ecto.Changeset{}} = Profiles.update_profile(profile, @invalid_attrs)
      assert profile == Profiles.get_profile!(profile.id)
    end

    test "delete_profile/1 deletes the profile" do
      profile = profile_fixture()
      assert {:ok, %Profile{}} = Profiles.delete_profile(profile)
      assert_raise Ecto.NoResultsError, fn -> Profiles.get_profile!(profile.id) end
    end

    test "change_profile/1 returns a profile changeset" do
      profile = profile_fixture()
      assert %Ecto.Changeset{} = Profiles.change_profile(profile)
    end
  end
end
