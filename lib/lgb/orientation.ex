defmodule Lgb.Orientation do
  @moduledoc """
  The Orientation context.
  """

  import Ecto.Query, warn: false
  alias Lgb.Orientation.ProfileSexualOrientation
  alias Lgb.Repo

  alias Lgb.Orientation.SexualOrientation

  @doc """
  Saves a profile's sexual orientation associations by replacing any existing links with new ones based on the provided categories.

  This function runs within a database transaction to ensure that either all changes are persisted or none at all. It deletes any current associations for the given profile and then inserts new associations for each sexual orientation whose category matches an element in the provided list.

  ## Examples

      iex> Lgb.Orientation.save_sexual_orientations(profile, ["bisexual", "heterosexual"])
      {:ok, _}
  """
  def save_sexual_orientations(profile, sexual_orientation_categories) do
    Repo.transaction(fn ->
      # First, delete existing associations
      Repo.delete_all(from so in ProfileSexualOrientation, where: so.profile_id == ^profile.id)

      # Get the sexual orientation records from the database based on categories
      sexual_orientations =
        from(so in SexualOrientation, where: so.category in ^sexual_orientation_categories)
        |> Repo.all()

      # Insert new associations
      Enum.each(sexual_orientations, fn sexual_orientation ->
        Repo.insert!(%ProfileSexualOrientation{
          profile_id: profile.id,
          sexual_orientation_id: sexual_orientation.id
        })
      end)
    end)
  end
end
