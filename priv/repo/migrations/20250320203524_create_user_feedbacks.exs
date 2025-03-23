defmodule Lgb.Repo.Migrations.CreateUserFeedbacks do
  use Ecto.Migration

  def change do
    create table(:feedbacks) do
      add :title, :string, null: false
      add :content, :text, null: false
      add :category, :string, null: false
      add :rating, :integer, null: false
      add :contact_consent, :boolean, default: false
      add :profile_id, references(:profiles, on_delete: :nilify_all)

      timestamps(type: :utc_datetime)
    end

    create index(:feedbacks, [:profile_id])
    create index(:feedbacks, [:category])
    create index(:feedbacks, [:rating])
  end
end
