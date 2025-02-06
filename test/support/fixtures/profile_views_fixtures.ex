defmodule Lgb.ProfileViewsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.ProfileViews` context.
  """

  @doc """
  Generate a profile_view.
  """
  def profile_view_fixture(attrs \\ %{}) do
    {:ok, profile_view} =
      attrs
      |> Enum.into(%{

      })
      |> Lgb.ProfileViews.create_profile_view()

    profile_view
  end
end
