defmodule Lgb.Repo.Migrations.CreateConversationMessages do
  use Ecto.Migration

  def change do
    create table(:conversation_messages) do
      add :content, :string
      add :read, :boolean, default: false, null: false
      add :profile_id, references(:profiles, on_delete: :nothing)
      add :conversation_id, references(:conversations, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:conversation_messages, [:profile_id])
    create index(:conversation_messages, [:conversation_id])
  end
end
