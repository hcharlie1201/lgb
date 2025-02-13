defmodule Lgb.Repo.Migrations.CreateStarredProfiles do
  use Ecto.Migration

  def change do
    create table(:starred_profiles) do
      add :profile_id, references(:profiles, on_delete: :delete_all)
      add :starred_profile_id, references(:profiles, on_delete: :delete_all)
      add :uuid, :uuid

      timestamps(type: :utc_datetime)
    end
  end
end
