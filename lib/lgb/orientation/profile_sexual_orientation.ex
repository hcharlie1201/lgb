defmodule Lgb.Orientation.ProfileSexualOrientation do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "profiles_sexual_orientations" do
    belongs_to :profile, Lgb.Profiles.Profile, type: :id, primary_key: true

    belongs_to :sexual_orientation, Lgb.Orientation.SexualOrientation,
      type: :id,
      primary_key: true
  end

  @doc false
  def changeset(sexual_orientation, attrs) do
    sexual_orientation
    |> cast(attrs, [:profile_id, :sexual_orientation_id])
    |> validate_required([:profile_id, :sexual_orientation_id])
    |> unique_constraint([:profile_id, :sexual_orientation_id])
  end
end
