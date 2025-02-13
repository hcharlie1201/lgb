defmodule Lgb.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Profiles` context.
  """

  @doc """
  Generate a profile.
  """
  def profile_fixture(user, attrs \\ %{}) do
    # Ensure user is a proper Ecto struct
    user =
      case user do
        %Lgb.Accounts.User{} -> user
        _ -> struct(Lgb.Accounts.User, user)
      end

    attrs =
      attrs
      |> Enum.into(%{
        biography: "some biography",
        city: "some city",
        handle: "some-handle-#{System.unique_integer()}",
        height_cm: 170,
        state: "some state",
        weight_lb: 150,
        age: 25,
        zip: "12345",
        uuid: System.unique_integer()
      })

    {:ok, profile} = Lgb.Profiles.create_profile(user, attrs)
    profile
  end
end
