defmodule Lgb.Repo.Migrations.CreateSubscrpitionPlans do
  use Ecto.Migration

  def change do
    create table(:subscription_plans) do
      add :name, :string
      add :stripe_price_id, :string

      timestamps(type: :utc_datetime)
    end
  end
end
