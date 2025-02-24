defmodule Lgb.Repo.Migrations.AddImageInConversationMessages do
  use Ecto.Migration

  def change do
    alter table(:conversation_messages) do
      add :image, :string
    end
  end
end
