defmodule Lgb.ProfilesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Profiles` context.
  """
  alias Lgb.Repo
  alias Lgb.Profiles.Hobby

  @hobby_1 "Cycling"
  @hobby_2 "Weightlifting"
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

    # Assign hobbies to profile
    Repo.insert!(%Hobby{name: @hobby_1})
    Repo.insert!(%Hobby{name: @hobby_2})
    profile
    |> Repo.preload(:hobbies)
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:hobbies, Repo.all(Hobby))
    |> Repo.update!()

    profile
  end
end
