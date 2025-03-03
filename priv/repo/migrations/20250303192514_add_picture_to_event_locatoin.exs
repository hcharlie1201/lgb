defmodule Lgb.Repo.Migrations.AddPictureToEventLocatoin do
  use Ecto.Migration

  def change do
    alter table(:event_locations) do
      add :image, :string
    end
  end
end
