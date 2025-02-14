defmodule Lgb.Repo.Migrations.CreatePosts do
  use Ecto.Migration

  def change do
    create table(:posts) do
      add :title, :string
      add :content, :string

      timestamps(type: :utc_datetime)
    end
  end
end
