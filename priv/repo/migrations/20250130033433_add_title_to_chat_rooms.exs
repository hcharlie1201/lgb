defmodule Lgb.Repo.Migrations.AddTitleToChatRooms do
  use Ecto.Migration

  def change do
    alter table(:chat_rooms) do
      add :title, :string
    end
  end
end
