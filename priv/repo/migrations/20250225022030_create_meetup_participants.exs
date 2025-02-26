defmodule Lgb.Repo.Migrations.CreateMeetupParticipants do
  use Ecto.Migration

  def change do
    create table(:event_participants) do
      add :event_location_id, references(:event_locations, on_delete: :delete_all), null: false
      add :profile_id, references(:profiles, on_delete: :delete_all), null: false
      add :joined_at, :utc_datetime, null: false, default: fragment("NOW()")

      timestamps()
    end

    create unique_index(:event_participants, [:event_location_id, :profile_id],
             name: :event_participant_profile_unique_index
           )
  end
end
