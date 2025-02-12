defmodule Lgb.Repo.Migrations.AddUuidsToConversationMessage do
  use Ecto.Migration

  def change do
    alter table(:conversation_messages) do
      add :uuid, :uuid, default: fragment("uuid_generate_v4()"), null: false
    end

    create unique_index(:conversation_messages, [:uuid])
  end
end
