defmodule Lgb.Repo.Migrations.CreateStripeCustomers do
  use Ecto.Migration

  def change do
    create table(:stripe_customers) do
      add :customer_id, :string
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:stripe_customers, [:user_id])
  end
end
