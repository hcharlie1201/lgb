defmodule Lgb.Repo.Migrations.ProfilesAddGeom do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION IF NOT EXISTS postgis;")

    alter table(:profiles) do
      add :geolocation, :geometry
    end
  end

  def down do
    alter table(:profiles) do
      remove :geolocation
    end

    execute("DROP EXTENSION IF EXISTS postgis;")
  end
end
