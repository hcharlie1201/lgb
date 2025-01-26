defmodule Lgb.SubscriptionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Subscriptions` context.
  """

  @doc """
  Generate a subscription_plan.
  """
  def subscription_plan_fixture(attrs \\ %{}) do
    {:ok, subscription_plan} =
      attrs
      |> Enum.into(%{
        name: "some name",
        stripe_price_id: "price_123",
        amount: 1000
      })
      |> Lgb.Subscriptions.create_subscription_plan()

    subscription_plan
  end
end
