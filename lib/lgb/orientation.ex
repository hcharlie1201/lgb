defmodule Lgb.Orientation do
  @moduledoc """
  The Orientation context.
  """

  import Ecto.Query, warn: false
  alias Lgb.Orientation.ProfileSexualOrientation
  alias Lgb.Repo

  alias Lgb.Orientation.SexualOrientation

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
