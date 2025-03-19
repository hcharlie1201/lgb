defmodule Lgb.OrientationFixtures do
  

  
  @doc """
  Generates a sexual orientation fixture for testing purposes.
  
  This function accepts an optional map of attributes to override default values, merges them into an empty map of defaults, and invokes `Lgb.Orientation.create_sexual_orientation/1`. It then pattern matches on the resulting `{:ok, sexual_orientation}` tuple and returns the created entity.
  
  ## Examples
  
      iex> sexual_orientation = sexual_orientation_fixture(%{name: "bisexual"})
      iex> sexual_orientation.name
      "bisexual"
  """
  def sexual_orientation_fixture(attrs \\ %{}) do
    {:ok, sexual_orientation} =
      attrs
      |> Enum.into(%{})
      |> Lgb.Orientation.create_sexual_orientation()

    sexual_orientation
  end
end
