defmodule Lgb.ProfileViewsTest do
  use Lgb.DataCase

  alias Lgb.ProfileViews
  import Lgb.AccountsFixtures
  import Lgb.ProfileViewsFixtures

  describe "profile_views" do
    setup do
      user = user_fixture()
      user_two = user_fixture()

      profile_one = Lgb.ProfilesFixtures.profile_fixture(user)

      profile_two = Lgb.ProfilesFixtures.profile_fixture(user_two)

      profile_view =
        profile_view_fixture(%{
          viewer_id: profile_one.id,
          viewed_profile_id: profile_two.id,
          last_viewed_at: DateTime.utc_now() |> DateTime.truncate(:second)
        })

      %{profile_view: profile_view}
    end

    @invalid_attrs %{}

    test "list_profile_views/0 returns all profile_views", %{profile_view: profile_view} do
      assert ProfileViews.list_profile_views() == [profile_view]
    end

    test "get_profile_view!/1 returns the profile_view with given id", %{
      profile_view: profile_view
    } do
      assert ProfileViews.get_profile_view!(profile_view.id) == profile_view
    end

    test "create_profile_view/1 with valid data creates a profile_view", %{
      profile_view: profile_view
    } do
      valid_attrs = %{last_viewed_at: DateTime.utc_now() |> DateTime.truncate(:second)}

      assert profile_view.last_viewed_at !=
               ProfileViews.create_or_update_profile_view(valid_attrs)
    end

    test "create_profile_view/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ProfileViews.create_profile_view(@invalid_attrs)
    end
  end
end
