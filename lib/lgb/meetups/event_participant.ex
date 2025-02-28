defmodule Lgb.Meetups.EventParticipant do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_participants" do
    field :joined_at, :utc_datetime

    belongs_to :event_location, Lgb.Meetups.EventLocation
    belongs_to :profile, Lgb.Profiles.Profile

    timestamps()
  end

  @spec changeset(
          {map(),
           %{
             optional(atom()) =>
               atom()
               | {:array | :assoc | :embed | :in | :map | :parameterized | :supertype | :try,
                  any()}
           }}
          | %{
              :__struct__ => atom() | %{:__changeset__ => any(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  def changeset(meetup_participant, attrs) do
    meetup_participant
    |> cast(attrs, [:event_location_id, :profile_id, :joined_at])
    |> validate_required([:event_location_id, :profile_id])
    |> unique_constraint([:event_location_id, :profile_id], name: :meetup_profile_unique_index)
    |> foreign_key_constraint(:event_location_id)
    |> foreign_key_constraint(:profile_id)
  end
end
