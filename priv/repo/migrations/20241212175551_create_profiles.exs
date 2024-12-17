defmodule Lgb.Repo.Migrations.CreateProfiles do
  use Ecto.Migration

  def change do
    create table(:profiles) do
      add :user_id, references(:users)
      add :handle, :string
      add :dob, :date
      add :height_cm, :integer
      add :weight_lb, :integer
      add :city, :string
      add :state, :string
      add :zip, :string
      add :biography, :text

      timestamps(type: :utc_datetime)
    end

    create unique_index(:profiles, [:handle])
  end
end
