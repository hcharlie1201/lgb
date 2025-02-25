defmodule Lgb.Repo.Migrations.CreateMeetupParticipants do
  use Ecto.Migration

  def change do
    create table(:meetup_participants) do
      add :meetup_id, references(:meetups, on_delete: :delete_all), null: false
      add :profile_id, references(:profiles, on_delete: :delete_all), null: false
      add :joined_at, :utc_datetime, null: false, default: fragment("NOW()")

      timestamps()
    end

    create index(:meetup_participants, [:meetup_id])
    create index(:meetup_participants, [:profile_id])
    create unique_index(:meetup_participants, [:meetup_id, :profile_id], name: :meetup_profile_unique_index)
  end
end
