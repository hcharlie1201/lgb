defmodule Lgb.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Profiles` context.
  """

  @doc """
  Generate a profile.
  """
  def profile_fixture(attrs \\ %{}) do
    {:ok, profile} =
      attrs
      |> Enum.into(%{
        biography: "some biography",
        city: "some city",
        dob: ~D[2024-12-11],
        handle: "some handle",
        height_cm: 42,
        state: "some state",
        weight_lb: 42,
        zip: "some zip"
      })
      |> Lgb.Profiles.create_profile()

    profile
  end
end
