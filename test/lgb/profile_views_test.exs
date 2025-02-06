defmodule Lgb.ProfileViewsTest do
  use Lgb.DataCase

  alias Lgb.ProfileViews

  describe "profile_views" do
    alias Lgb.ProfileViews.ProfileView

    import Lgb.ProfileViewsFixtures

    @invalid_attrs %{}

    test "list_profile_views/0 returns all profile_views" do
      profile_view = profile_view_fixture()
      assert ProfileViews.list_profile_views() == [profile_view]
    end

    test "get_profile_view!/1 returns the profile_view with given id" do
      profile_view = profile_view_fixture()
      assert ProfileViews.get_profile_view!(profile_view.id) == profile_view
    end

    test "create_profile_view/1 with valid data creates a profile_view" do
      valid_attrs = %{}

      assert {:ok, %ProfileView{} = profile_view} = ProfileViews.create_profile_view(valid_attrs)
    end

    test "create_profile_view/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ProfileViews.create_profile_view(@invalid_attrs)
    end

    test "update_profile_view/2 with valid data updates the profile_view" do
      profile_view = profile_view_fixture()
      update_attrs = %{}

      assert {:ok, %ProfileView{} = profile_view} = ProfileViews.update_profile_view(profile_view, update_attrs)
    end

    test "update_profile_view/2 with invalid data returns error changeset" do
      profile_view = profile_view_fixture()
      assert {:error, %Ecto.Changeset{}} = ProfileViews.update_profile_view(profile_view, @invalid_attrs)
      assert profile_view == ProfileViews.get_profile_view!(profile_view.id)
    end

    test "delete_profile_view/1 deletes the profile_view" do
      profile_view = profile_view_fixture()
      assert {:ok, %ProfileView{}} = ProfileViews.delete_profile_view(profile_view)
      assert_raise Ecto.NoResultsError, fn -> ProfileViews.get_profile_view!(profile_view.id) end
    end

    test "change_profile_view/1 returns a profile_view changeset" do
      profile_view = profile_view_fixture()
      assert %Ecto.Changeset{} = ProfileViews.change_profile_view(profile_view)
    end
  end
end
