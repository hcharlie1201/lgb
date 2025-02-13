defmodule Lgb.Profiles.Starred do
  use Ecto.Schema
  import Ecto.Changeset

  schema "starred_profiles" do
    belongs_to :profile, Lgb.Profiles.Profile
    # Changed from has_one to belongs_to
    belongs_to :starred_profile, Lgb.Profiles.Profile
    field :uuid, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(starred, attrs) do
    starred
    |> cast(attrs, [:profile_id, :starred_profile_id])
    # Add to required fields
    |> validate_required([:profile_id, :starred_profile_id])
  end
end
