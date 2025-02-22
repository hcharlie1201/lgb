defmodule Lgb.Repo.Migrations.CreateDatingGoals do
  use Ecto.Migration

  def change do
    create table(:dating_goals) do
      add :name, :string
      add :description, :string
      timestamps()
    end

    create unique_index(:dating_goals, [:name])

    create table(:profiles_dating_goals, primary_key: false) do
      add :profile_id, references(:profiles)
      add :dating_goal_id, references(:dating_goals)
    end

    create unique_index(:profiles_dating_goals, [:profile_id, :dating_goal_id])
  end
end
