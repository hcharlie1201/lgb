defmodule Lgb.Profiles.ProfileHobby do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "profiles_hobbies" do
    belongs_to :profile, Lgb.Profiles.Profile, type: :id, primary_key: true
    belongs_to :hobby, Lgb.Profiles.Hobby, type: :id, primary_key: true
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:profile_id, :hobby_id])
    |> validate_required([:profile_id, :hobby_id])
    |> unique_constraint(
      [:profile_id, :hobby_id],
      name: :profiles_hobbies_profile_id_hobby_id_index
    )
  end
end
