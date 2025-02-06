defmodule Lgb.ProfileViews.ProfileView do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profile_views" do
    belongs_to :viewer, Lgb.Profiles.Profile
    belongs_to :viewed_profile, Lgb.Profiles.Profile
    field :last_viewed_at, :utc_datetime

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile_view, attrs) do
    profile_view
    |> cast(attrs, [:viewer_id, :viewed_profile_id, :last_viewed_at])
    |> validate_required([:viewer_id, :viewed_profile_id, :last_viewed_at])
  end
end
