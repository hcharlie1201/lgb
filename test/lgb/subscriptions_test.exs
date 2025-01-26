defmodule Lgb.SubscriptionsTest do
  use Lgb.DataCase

  alias Lgb.Subscriptions

  describe "subscription_plans" do
    alias Lgb.Subscriptions.SubscriptionPlan

    import Lgb.SubscriptionsFixtures

    @invalid_attrs %{stripe_price_id: nil}

    test "list_subscription_plans/0 returns all subscription_plans" do
      subscription_plan = subscription_plan_fixture()
      assert Subscriptions.list_subscription_plans() == [subscription_plan]
    end

    test "get_subscription_plan!/1 returns the subscription_plan with given id" do
      subscription_plan = subscription_plan_fixture()
      assert Subscriptions.get_subscription_plan!(subscription_plan.id) == subscription_plan
    end

    test "create_subscription_plan/1 with valid data creates a subscription_plan" do
      valid_attrs = %{stripe_price_id: "price_123", name: "Basic Plan"}

      assert {:ok, %SubscriptionPlan{} = subscription_plan} = Subscriptions.create_subscription_plan(valid_attrs)
      assert subscription_plan.name == "Basic Plan"
      assert subscription_plan.stripe_price_id == "price_123"
    end

    test "create_subscription_plan/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Subscriptions.create_subscription_plan(@invalid_attrs)
    end

    test "update_subscription_plan/2 with valid data updates the subscription_plan" do
      subscription_plan = subscription_plan_fixture()
      update_attrs = %{name: "Premium Plan", stripe_price_id: "price_456"}

      assert {:ok, %SubscriptionPlan{} = subscription_plan} = Subscriptions.update_subscription_plan(subscription_plan, update_attrs)
      assert subscription_plan.name == "Premium Plan"
      assert subscription_plan.stripe_price_id == "price_456"
    end

    test "update_subscription_plan/2 with invalid data returns error changeset" do
      subscription_plan = subscription_plan_fixture()
      assert {:error, %Ecto.Changeset{}} = Subscriptions.update_subscription_plan(subscription_plan, @invalid_attrs)
      assert subscription_plan == Subscriptions.get_subscription_plan!(subscription_plan.id)
    end

    test "delete_subscription_plan/1 deletes the subscription_plan" do
      subscription_plan = subscription_plan_fixture()
      assert {:ok, %SubscriptionPlan{}} = Subscriptions.delete_subscription_plan(subscription_plan)
      assert_raise Ecto.NoResultsError, fn -> Subscriptions.get_subscription_plan!(subscription_plan.id) end
    end

    test "change_subscription_plan/1 returns a subscription_plan changeset" do
      subscription_plan = subscription_plan_fixture()
      assert %Ecto.Changeset{} = Subscriptions.change_subscription_plan(subscription_plan)
    end
  end
end
