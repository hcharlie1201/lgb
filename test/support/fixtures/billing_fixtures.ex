defmodule Lgb.BillingFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Billing` context.
  """

  @doc """
  Generate a stripe_customer.
  """
  def stripe_customer_fixture(attrs \\ %{}) do
    user = Lgb.AccountsFixtures.user_fixture()

    {:ok, stripe_customer} =
      attrs
      |> Enum.into(%{
        "name" => "Test Customer",
        "address" => %{
          "line1" => "123 Test St",
          "line2" => "",
          "city" => "Test City",
          "state" => "TS",
          "postal_code" => "12345",
          "country" => "US"
        }
      })
      |> then(&Lgb.Billing.create_stripe_customer(user, &1))

    stripe_customer
  end

  @doc """
  Generate a stripe_subscription.
  """
  def subscription_plan_fixture(attrs \\ %{}) do
    {:ok, subscription_plan} =
      attrs
      |> Enum.into(%{
        id: 42,
        stripe_price_id: "price_123"
      })
      |> then(&struct!(Lgb.Subscriptions.SubscriptionPlan, &1))
      |> Lgb.Repo.insert()

    subscription_plan
  end

  def stripe_subscription_fixture(subscription_plan) do
    stripe_customer = stripe_customer_fixture()

    {:ok, stripe_subscription} =
      Lgb.Billing.create_stripe_subscription(stripe_customer, subscription_plan)

    stripe_subscription
  end
end
