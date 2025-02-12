defmodule Lgb.Repo.Migrations.AddUuids do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\""

    alter table(:users) do
      add :uuid, :uuid, default: fragment("uuid_generate_v4()"), null: false
    end

    alter table(:profiles) do
      add :uuid, :uuid, default: fragment("uuid_generate_v4()"), null: false
    end

    alter table(:conversations) do
      add :uuid, :uuid, default: fragment("uuid_generate_v4()"), null: false
    end

    create unique_index(:users, [:uuid])
    create unique_index(:profiles, [:uuid])
    create unique_index(:conversations, [:uuid])
  end
end
