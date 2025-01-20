defmodule Lgb.Billing.StripeCustomer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stripe_customers" do
    field :customer_id, :integer
    belongs_to :users, Lgb.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(stripe_customer, attrs) do
    stripe_customer
    |> cast(attrs, [:customer_id])
    |> validate_required([:customer_id])
  end
end
