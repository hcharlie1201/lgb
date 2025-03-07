defmodule Lgb.Repo.Migrations.CreateHobbies do
  use Ecto.Migration

  def change do
    create table(:hobbies) do
      add :name, :string
      timestamps()
    end

    create unique_index(:hobbies, [:name])

    create table(:profiles_hobbies, primary_key: false) do
      add :profile_id, references(:profiles)
      add :hobby_id, references(:hobbies)
    end

    create unique_index(:profiles_hobbies, [:profile_id, :hobby_id])
  end
end
