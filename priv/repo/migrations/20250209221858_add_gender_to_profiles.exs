defmodule Lgb.Repo.Migrations.AddGenderToProfiles do
  use Ecto.Migration

  def change do
    create_query = "CREATE TYPE gender_type AS ENUM ('male', 'female', 'non_binary')"
    drop_query = "DROP TYPE gender_type"
    execute(create_query, drop_query)

    alter table(:profiles) do
      add :gender, :gender_type
    end
  end
end
