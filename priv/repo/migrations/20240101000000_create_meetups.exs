defmodule Lgb.Repo.Migrations.CreateMeetups do
  use Ecto.Migration

  def change do
    # First create the enum type for categories
    create_categories_enum()

    create table(:meetups) do
      add :title, :string, null: false
      add :description, :text, null: false
      add :date, :utc_datetime, null: false
      add :location_name, :string, null: false
      add :latitude, :float, null: false
      add :longitude, :float, null: false
      add :max_participants, :integer, default: 10
      add :creator_id, references(:profiles, on_delete: :delete_all), null: false
      add :category, :meetup_category, null: false

      timestamps()
    end

    create index(:meetups, [:creator_id])
  end

  defp create_categories_enum do
    create type(:meetup_category, :enum, [
      "outdoors_activities",
      "sport",
      "technology",
      "hobbies_and_passion",
      "support_and_coaching",
      "art_and_culture",
      "games",
      "dancing",
      "music",
      "reading",
      "animals_and_pets"
    ])
  end
end
