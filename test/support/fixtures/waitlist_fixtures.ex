defmodule Lgb.WaitlistFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Waitlist` context.
  """

  @doc """
  Generate a waitlist_entry.
  """
  def waitlist_entry_fixture(attrs \\ %{}) do
    {:ok, waitlist_entry} =
      attrs
      |> Enum.into(%{
        email: "some email"
      })
      |> Lgb.Waitlist.create_waitlist_entry()

    waitlist_entry
  end
end
