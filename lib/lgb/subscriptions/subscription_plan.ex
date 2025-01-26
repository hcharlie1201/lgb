defmodule Lgb.Subscriptions.SubscriptionPlan do
  use Ecto.Schema
  import Ecto.Changeset

  schema "subscription_plans" do
    field :name, :string
    field :stripe_price_id, :string
    field :amount, :integer, virtual: true
    field :interval_count, :integer, virtual: true
    field :interval, :string, virtual: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(subscription_plan, attrs) do
    subscription_plan
    |> cast(attrs, [:name, :stripe_price_id])
    |> validate_required([:stripe_price_id])
  end
end
