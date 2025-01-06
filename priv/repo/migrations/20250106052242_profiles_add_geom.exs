defmodule Lgb.Repo.Migrations.ProfilesAddGeom do
  use Ecto.Migration

  def up do
    alter table(:profiles) do
      add :geolocation, :geometry
    end
  end

  def down do
    alter table(:profiles) do
      remove :geolocation
    end
  end
end
