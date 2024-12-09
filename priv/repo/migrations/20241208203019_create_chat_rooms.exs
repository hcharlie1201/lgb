defmodule Lgb.Repo.Migrations.CreateChatRooms do
  use Ecto.Migration

  def change do
    create table(:chat_rooms) do
      add :limit, :integer
      add :description, :string

      timestamps(type: :utc_datetime)
    end
  end
end
