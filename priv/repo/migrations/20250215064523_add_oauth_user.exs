defmodule Lgb.Repo.Migrations.AddOauthUser do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :is_oauth_user, :boolean, default: false, null: false
      modify :hashed_password, :string, null: true
    end
  end
end
