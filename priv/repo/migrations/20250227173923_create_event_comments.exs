defmodule Lgb.Repo.Migrations.CreateEventComments do
  use Ecto.Migration

  def change do
    create table(:event_comments) do
      add :event_location_id, references(:event_locations, on_delete: :delete_all), null: false
      add :profile_id, references(:profiles, on_delete: :delete_all), null: false
      add :content, :text, null: false
      add :likes_count, :integer, default: 0

      timestamps()
    end

    create table(:comment_likes) do
      add :event_comment_id, references(:event_comments, on_delete: :delete_all), null: false
      add :profile_id, references(:profiles, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:comment_likes, [:event_comment_id, :profile_id],
             name: :unique_comment_like
           )

    create table(:event_comment_replies) do
      add :event_comment_id, references(:event_comments, on_delete: :delete_all), null: false
      add :profile_id, references(:profiles, on_delete: :delete_all), null: false
      add :content, :text, null: false
      add :likes_count, :integer, default: 0

      timestamps()
    end

    create table(:comment_reply_likes) do
      add :event_comment_reply_id, references(:event_comment_replies, on_delete: :delete_all),
        null: false

      add :profile_id, references(:profiles, on_delete: :delete_all), null: false

      timestamps()
    end

    create unique_index(:comment_reply_likes, [:event_comment_reply_id, :profile_id],
             name: :unique_comment_reply_like
           )
  end
end
