defmodule Lgb.Repo.Migrations.CreateSexualOrientations do
  use Ecto.Migration

  def change do
    create_query = """
    CREATE TYPE romantic_category AS ENUM (
      'bisexual_gay_leaning',
      'bisexual',
      'bisexual_straight_leaning',
      'bisexual_straight_curious',
      'bisexual_gay_curious',
      'straight',
      'asexual',
      'demisexual',
      'sapiosexual',
      'graysexual',
      'pansexual',
      'greysexual',
      'gay',
      'lesbian'
    )
    """

    drop_query = "DROP TYPE romantic_category"
    execute(create_query, drop_query)

    create table(:sexual_orientations) do
      add :category, :romantic_category, null: false
      timestamps(type: :utc_datetime)
    end

    create unique_index(:sexual_orientations, [:category])

    create table(:profiles_sexual_orientations, primary_key: false) do
      add :profile_id, references(:profiles)
      add :sexual_orientation_id, references(:sexual_orientations)
    end

    create unique_index(:profiles_sexual_orientations, [:profile_id, :sexual_orientation_id])
  end
end
