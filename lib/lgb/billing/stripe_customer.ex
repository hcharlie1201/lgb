defmodule Lgb.Billing.StripeCustomer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stripe_customers" do
    field :customer_id, :integer
    belongs_to :user, Lgb.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(stripe_customer, attrs) do
    stripe_customer
    |> cast(attrs, [:customer_id, :user_id])
    |> validate_required([:customer_id, :user_id])
  end
end
