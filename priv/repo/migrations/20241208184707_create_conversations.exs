defmodule Lgb.Repo.Migrations.CreateConversations do
  use Ecto.Migration

  def change do
    create table(:conversations) do
      add :sender_profile_id, references(:profiles, on_delete: :nothing)
      add :receiver_profile_id, references(:profiles, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:conversations, [:sender_profile_id])
    create index(:conversations, [:receiver_profile_id])
  end
end
