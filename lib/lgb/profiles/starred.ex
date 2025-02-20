defmodule Lgb.Profiles.Starred do
  use Ecto.Schema
  import Ecto.Changeset

  schema "starred_profiles" do
    belongs_to :profile, Lgb.Profiles.Profile
    belongs_to :starred_profile, Lgb.Profiles.Profile
    field :uuid, Ecto.UUID, read_after_writes: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(starred, attrs) do
    starred
    |> cast(attrs, [:profile_id, :starred_profile_id])
    |> validate_required([:profile_id, :starred_profile_id])
  end
end
