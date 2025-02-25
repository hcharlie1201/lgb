defmodule Lgb.Meetups.MeetupParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "meetup_participants" do
    field :joined_at, :utc_datetime
    
    belongs_to :meetup, Lgb.Meetups.Meetup
    belongs_to :profile, Lgb.Profiles.Profile

    timestamps()
  end

  def changeset(meetup_participant, attrs) do
    meetup_participant
    |> cast(attrs, [:meetup_id, :profile_id, :joined_at])
    |> validate_required([:meetup_id, :profile_id])
    |> unique_constraint([:meetup_id, :profile_id], name: :meetup_profile_unique_index)
    |> foreign_key_constraint(:meetup_id)
    |> foreign_key_constraint(:profile_id)
    |> put_joined_at()
  end

  defp put_joined_at(changeset) do
    case get_field(changeset, :joined_at) do
      nil -> put_change(changeset, :joined_at, DateTime.utc_now() |> DateTime.truncate(:second))
      _ -> changeset
    end
  end
end
