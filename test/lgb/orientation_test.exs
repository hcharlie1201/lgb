defmodule Lgb.OrientationTest do
  use Lgb.DataCase

  alias Lgb.Orientation

  describe "sexual_orientations" do
    alias Lgb.Orientation.SexualOrientation

    import Lgb.OrientationFixtures

    @invalid_attrs %{}

    test "list_sexual_orientations/0 returns all sexual_orientations" do
      sexual_orientation = sexual_orientation_fixture()
      assert Orientation.list_sexual_orientations() == [sexual_orientation]
    end

    test "get_sexual_orientation!/1 returns the sexual_orientation with given id" do
      sexual_orientation = sexual_orientation_fixture()
      assert Orientation.get_sexual_orientation!(sexual_orientation.id) == sexual_orientation
    end

    test "create_sexual_orientation/1 with valid data creates a sexual_orientation" do
      valid_attrs = %{}

      assert {:ok, %SexualOrientation{} = sexual_orientation} = Orientation.create_sexual_orientation(valid_attrs)
    end

    test "create_sexual_orientation/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Orientation.create_sexual_orientation(@invalid_attrs)
    end

    test "update_sexual_orientation/2 with valid data updates the sexual_orientation" do
      sexual_orientation = sexual_orientation_fixture()
      update_attrs = %{}

      assert {:ok, %SexualOrientation{} = sexual_orientation} = Orientation.update_sexual_orientation(sexual_orientation, update_attrs)
    end

    test "update_sexual_orientation/2 with invalid data returns error changeset" do
      sexual_orientation = sexual_orientation_fixture()
      assert {:error, %Ecto.Changeset{}} = Orientation.update_sexual_orientation(sexual_orientation, @invalid_attrs)
      assert sexual_orientation == Orientation.get_sexual_orientation!(sexual_orientation.id)
    end

    test "delete_sexual_orientation/1 deletes the sexual_orientation" do
      sexual_orientation = sexual_orientation_fixture()
      assert {:ok, %SexualOrientation{}} = Orientation.delete_sexual_orientation(sexual_orientation)
      assert_raise Ecto.NoResultsError, fn -> Orientation.get_sexual_orientation!(sexual_orientation.id) end
    end

    test "change_sexual_orientation/1 returns a sexual_orientation changeset" do
      sexual_orientation = sexual_orientation_fixture()
      assert %Ecto.Changeset{} = Orientation.change_sexual_orientation(sexual_orientation)
    end
  end
end
