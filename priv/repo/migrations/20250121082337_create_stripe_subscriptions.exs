defmodule Lgb.Repo.Migrations.CreateStripeSubscriptions do
  use Ecto.Migration

  def change do
    create table(:stripe_subscriptions) do
      add :subscription_id, :string
      add :stripe_customer_id, references(:stripe_customers, on_delete: :nothing)
      add :subscription_plan_id, references(:subscription_plans, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:stripe_subscriptions, [:stripe_customer_id])
    create index(:stripe_subscriptions, [:subscription_plan_id])
  end
end
