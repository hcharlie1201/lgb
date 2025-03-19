defmodule Lgb.OrientationTest do
  use Lgb.DataCase

  alias Lgb.Orientation
  alias Lgb.Orientation.{SexualOrientation, ProfileSexualOrientation}
  alias Lgb.Profiles.Profile
  import Lgb.{ProfilesFixtures, AccountsFixtures}

  describe "sexual orientations" do
    setup do
      # Create a user and profile
      user = user_fixture()
      profile = profile_fixture(user)

      # Create sexual orientation records in the database
      bisexual = Repo.insert!(%SexualOrientation{category: :bisexual})
      gay = Repo.insert!(%SexualOrientation{category: :gay})
      straight = Repo.insert!(%SexualOrientation{category: :straight})

      %{
        profile: profile,
        orientations: %{
          bisexual: bisexual,
          gay: gay,
          straight: straight
        }
      }
    end

    test "save_sexual_orientations/2 creates correct associations", %{
      profile: profile,
      orientations: orientations
    } do
      # Initial check that profile has no orientations
      assert Repo.all(from so in ProfileSexualOrientation, where: so.profile_id == ^profile.id) ==
               []

      # Call the function with two categories
      selected_categories = [:bisexual, :gay]
      Orientation.save_sexual_orientations(profile, selected_categories)

      # Check that correct associations were created
      associations =
        Repo.all(
          from pso in ProfileSexualOrientation,
            where: pso.profile_id == ^profile.id,
            select: pso.sexual_orientation_id
        )

      assert length(associations) == 2
      assert orientations.bisexual.id in associations
      assert orientations.gay.id in associations
      refute orientations.straight.id in associations

      # Update to different orientations
      new_categories = [:straight]
      Orientation.save_sexual_orientations(profile, new_categories)

      # Check that old associations were replaced
      new_associations =
        Repo.all(
          from pso in ProfileSexualOrientation,
            where: pso.profile_id == ^profile.id,
            select: pso.sexual_orientation_id
        )

      assert length(new_associations) == 1
      assert orientations.straight.id in new_associations
      refute orientations.bisexual.id in new_associations
      refute orientations.gay.id in new_associations

      # Test with empty list
      Orientation.save_sexual_orientations(profile, [])

      empty_associations =
        Repo.all(
          from pso in ProfileSexualOrientation,
            where: pso.profile_id == ^profile.id
        )

      assert empty_associations == []
    end

    test "save_sexual_orientations/2 handles non-existent categories", %{profile: profile} do
      # Try to save with non-existent categories
      assert_raise Ecto.Query.CastError, fn ->
        Orientation.save_sexual_orientations(profile, [:nonexistent, :another_fake])
      end
    end

    test "save_sexual_orientations/2 is idempotent", %{
      profile: profile,
      orientations: orientations
    } do
      # Call the function twice with the same categories
      selected_categories = [:bisexual, :gay]
      Orientation.save_sexual_orientations(profile, selected_categories)
      Orientation.save_sexual_orientations(profile, selected_categories)

      # Should still only have two associations
      associations =
        Repo.all(
          from pso in ProfileSexualOrientation,
            where: pso.profile_id == ^profile.id,
            select: pso.sexual_orientation_id
        )

      assert length(associations) == 2
      assert orientations.bisexual.id in associations
      assert orientations.gay.id in associations
    end
  end
end
