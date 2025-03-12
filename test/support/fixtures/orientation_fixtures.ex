defmodule Lgb.OrientationFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Orientation` context.
  """

  @doc """
  Generate a sexual_orientation.
  """
  def sexual_orientation_fixture(attrs \\ %{}) do
    {:ok, sexual_orientation} =
      attrs
      |> Enum.into(%{

      })
      |> Lgb.Orientation.create_sexual_orientation()

    sexual_orientation
  end
end
