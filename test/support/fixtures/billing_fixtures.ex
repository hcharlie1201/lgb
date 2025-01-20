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
end
