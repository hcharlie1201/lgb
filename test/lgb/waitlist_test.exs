defmodule Lgb.WaitlistTest do
  use Lgb.DataCase

  alias Lgb.Waitlist

  describe "waitlist_entries" do
    alias Lgb.Waitlist.WaitlistEntry

    import Lgb.WaitlistFixtures

    @invalid_attrs %{email: nil}

    test "list_waitlist_entries/0 returns all waitlist_entries" do
      waitlist_entry = waitlist_entry_fixture()
      assert Waitlist.list_waitlist_entries() == [waitlist_entry]
    end

    test "get_waitlist_entry!/1 returns the waitlist_entry with given id" do
      waitlist_entry = waitlist_entry_fixture()
      assert Waitlist.get_waitlist_entry!(waitlist_entry.id) == waitlist_entry
    end

    test "create_waitlist_entry/1 with valid data creates a waitlist_entry" do
      valid_attrs = %{email: "some email"}

      assert {:ok, %WaitlistEntry{} = waitlist_entry} = Waitlist.create_waitlist_entry(valid_attrs)
      assert waitlist_entry.email == "some email"
    end

    test "create_waitlist_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Waitlist.create_waitlist_entry(@invalid_attrs)
    end

    test "update_waitlist_entry/2 with valid data updates the waitlist_entry" do
      waitlist_entry = waitlist_entry_fixture()
      update_attrs = %{email: "some updated email"}

      assert {:ok, %WaitlistEntry{} = waitlist_entry} = Waitlist.update_waitlist_entry(waitlist_entry, update_attrs)
      assert waitlist_entry.email == "some updated email"
    end

    test "update_waitlist_entry/2 with invalid data returns error changeset" do
      waitlist_entry = waitlist_entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Waitlist.update_waitlist_entry(waitlist_entry, @invalid_attrs)
      assert waitlist_entry == Waitlist.get_waitlist_entry!(waitlist_entry.id)
    end

    test "delete_waitlist_entry/1 deletes the waitlist_entry" do
      waitlist_entry = waitlist_entry_fixture()
      assert {:ok, %WaitlistEntry{}} = Waitlist.delete_waitlist_entry(waitlist_entry)
      assert_raise Ecto.NoResultsError, fn -> Waitlist.get_waitlist_entry!(waitlist_entry.id) end
    end

    test "change_waitlist_entry/1 returns a waitlist_entry changeset" do
      waitlist_entry = waitlist_entry_fixture()
      assert %Ecto.Changeset{} = Waitlist.change_waitlist_entry(waitlist_entry)
    end
  end
end
