defmodule Lgb.Repo.Migrations.CreateProfileViews do
  use Ecto.Migration

  def change do
    create table(:profile_views) do
      add :viewer_id, references(:profiles, on_delete: :nothing)
      add :viewed_profile_id, references(:profiles, on_delete: :nothing)
      add :last_viewed_at, :utc_datetime, null: false

      timestamps(type: :utc_datetime)
    end

    create index(:profile_views, [:viewer_id])
    create index(:profile_views, [:viewed_profile_id])

    create unique_index(:profile_views, [:viewer_id, :viewed_profile_id],
             name: :unique_profile_view
           )
  end
end
