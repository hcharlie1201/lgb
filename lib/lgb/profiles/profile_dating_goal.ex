defmodule Lgb.Profiles.ProfileDatingGoal do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "profiles_dating_goals" do
    belongs_to :profile, Lgb.Profiles.Profile, type: :id, primary_key: true
    belongs_to :dating_goal, Lgb.Profiles.DatingGoal, type: :id, primary_key: true
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:profile_id, :dating_goal_id])
    |> validate_required([:profile_id, :dating_goal_id])
    |> unique_constraint(
      [:profile_id, :dating_goal_id],
      name: :profiles_dating_goals_profile_id_dating_goal_id_index
    )
  end
end
