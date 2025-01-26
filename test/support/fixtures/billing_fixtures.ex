defmodule Lgb.BillingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Billing` context.
  """

  @doc """
  Generate a stripe_customer.
  """
  def stripe_customer_fixture(attrs \\ %{}) do
    {:ok, stripe_customer} =
      attrs
      |> Enum.into(%{
        customer_id: 42
      })
      |> Lgb.Billing.create_stripe_customer()

    stripe_customer
  end

  @doc """
  Generate a stripe_subscription.
  """
  def stripe_subscription_fixture(attrs \\ %{}) do
    stripe_customer = stripe_customer_fixture()
    
    {:ok, stripe_subscription} =
      attrs
      |> Enum.into(%{
        subscription_id: "some subscription_id",
        stripe_customer_id: stripe_customer.id,
        subscription_plan_id: 42
      })
      |> then(&struct!(Lgb.Billing.StripeSubscription, &1))
      |> Lgb.Repo.insert()

    stripe_subscription
  end
end
