defmodule Lgb.Repo.Migrations.CreateProfilePictures do
  use Ecto.Migration

  def change do
    create table(:profile_pictures) do
      add :profile_id, references(:profiles)
      add :image, :string

      timestamps(type: :utc_datetime)
    end
  end
end
