defmodule Lgb.Repo.Migrations.CreateMeetups do
  use Ecto.Migration

  def change do
    create_query = """
    CREATE TYPE meetup_category AS ENUM (
      'outdoors_activities',
      'sport',
      'technology',
      'hobbies_and_passion',
      'support_and_coaching',
      'art_and_culture',
      'games',
      'dancing',
      'music',
      'reading',
      'animals_and_pets'
    )
    """

    drop_query = "DROP TYPE meetup_category"
    execute(create_query, drop_query)

    create table(:event_locations) do
      add :title, :string, null: false
      add :description, :text, null: false
      add :date, :utc_datetime, null: false
      add :location_name, :string, null: false
      add :geolocation, :geometry
      add :max_participants, :integer, default: 20
      add :creator_id, references(:profiles, on_delete: :delete_all), null: false
      add :category, :meetup_category, null: false

      timestamps()
    end

    create index(:event_locations, [:creator_id])
  end
end
