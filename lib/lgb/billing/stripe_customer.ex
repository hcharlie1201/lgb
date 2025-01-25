defmodule Lgb.Billing.StripeCustomer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stripe_customers" do
    has_one :stripe_subscription, Lgb.Billing.StripeSubscription
    belongs_to :user, Lgb.Accounts.User
    field :customer_id, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(stripe_customer, attrs) do
    stripe_customer
    |> cast(attrs, [:customer_id, :user_id])
    |> validate_required([:customer_id, :user_id])
  end
end
