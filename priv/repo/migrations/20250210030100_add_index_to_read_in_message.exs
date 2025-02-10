defmodule Lgb.Repo.Migrations.AddIndexToReadInMessage do
  use Ecto.Migration

  def change do
    create index(:conversation_messages, [:read, :profile_id])
  end
end
