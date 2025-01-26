defmodule Lgb.BillingTest do
  use Lgb.DataCase

  alias Lgb.Billing

  describe "stripe_customers" do
    alias Lgb.Billing.StripeCustomer

    import Lgb.BillingFixtures

    @invalid_attrs %{customer_id: nil}

    test "list_stripe_customers/0 returns all stripe_customers" do
      stripe_customer = stripe_customer_fixture()
      assert Billing.list_stripe_customers() == [stripe_customer]
    end

    test "get_stripe_customer!/1 returns the stripe_customer with given id" do
      stripe_customer = stripe_customer_fixture()
      assert Billing.get_stripe_customer!(stripe_customer.id) == stripe_customer
    end

    test "create_stripe_customer/2 with valid data creates a stripe_customer" do
      user = Lgb.AccountsFixtures.user_fixture()

      valid_attrs = %{
        "name" => "Test Customer",
        "address" => %{
          "line1" => "123 Test St",
          "line2" => "",
          "city" => "Test City",
          "state" => "TS",
          "postal_code" => "12345",
          "country" => "US"
        }
      }

      assert {:ok, %StripeCustomer{} = stripe_customer} =
               Billing.create_stripe_customer(user, valid_attrs)

      assert stripe_customer.customer_id != nil
    end

    test "update_stripe_customer/2 with valid data updates the stripe_customer" do
      stripe_customer = stripe_customer_fixture()
      update_attrs = %{customer_id: "cus_new123"}

      assert {:ok, %StripeCustomer{} = stripe_customer} =
               Billing.update_stripe_customer(stripe_customer, update_attrs)

      assert stripe_customer.customer_id == "cus_new123"
    end

    test "update_stripe_customer/2 with invalid data returns error changeset" do
      stripe_customer = stripe_customer_fixture()

      assert {:error, %Ecto.Changeset{}} =
               Billing.update_stripe_customer(stripe_customer, @invalid_attrs)

      assert stripe_customer == Billing.get_stripe_customer!(stripe_customer.id)
    end

    test "delete_stripe_customer/1 deletes the stripe_customer" do
      stripe_customer = stripe_customer_fixture()
      assert {:ok, %StripeCustomer{}} = Billing.delete_stripe_customer(stripe_customer)
      assert_raise Ecto.NoResultsError, fn -> Billing.get_stripe_customer!(stripe_customer.id) end
    end

    test "change_stripe_customer/1 returns a stripe_customer changeset" do
      stripe_customer = stripe_customer_fixture()
      assert %Ecto.Changeset{} = Billing.change_stripe_customer(stripe_customer)
    end
  end

  describe "stripe_subscriptions" do
    alias Lgb.Billing.StripeSubscription
    import Lgb.BillingFixtures

    @invalid_attrs %{subscription_id: nil, stripe_customer_id: nil, subscription_plan_id: nil}

    test "list_stripe_subscriptions/0 returns all stripe_subscriptions" do
      subscription_plan = subscription_plan_fixture()
      stripe_subscription = stripe_subscription_fixture(subscription_plan)
      assert Billing.list_stripe_subscriptions() == [stripe_subscription]
    end

    test "get_stripe_subscription!/1 returns the stripe_subscription with given id" do
      subscription_plan = subscription_plan_fixture()
      stripe_subscription = stripe_subscription_fixture(subscription_plan)
      assert Billing.get_stripe_subscription!(stripe_subscription.id) == stripe_subscription
    end

    test "create_stripe_subscription/2 with valid data creates a stripe_subscription" do
      stripe_customer = stripe_customer_fixture()
      subscription_plan = subscription_plan_fixture()

      assert {:ok, %StripeSubscription{} = stripe_subscription} =
               Billing.create_stripe_subscription(stripe_customer, subscription_plan)

      assert stripe_subscription.subscription_plan_id == subscription_plan.id
    end

    test "create_stripe_subscription/2 with invalid data returns error" do
      stripe_customer = stripe_customer_fixture()
      invalid_plan = %{id: 999, stripe_price_id: nil}
      assert {:error, _} = Billing.create_stripe_subscription(stripe_customer, invalid_plan)
    end

    test "update_stripe_subscription/2 with valid data updates the stripe_subscription" do
      subscription_plan = subscription_plan_fixture()
      stripe_subscription = stripe_subscription_fixture(subscription_plan)

      update_attrs = %{
        subscription_id: "some updated subscription_id",
        subscription_plan_id: subscription_plan.id
      }

      assert {:ok, %StripeSubscription{} = stripe_subscription} =
               Billing.update_stripe_subscription(stripe_subscription, update_attrs)

      assert stripe_subscription.subscription_id == "some updated subscription_id"
    end

    test "update_stripe_subscription/2 with invalid data returns error changeset" do
      subscription_plan = subscription_plan_fixture()
      stripe_subscription = stripe_subscription_fixture(subscription_plan)

      assert {:error, %Ecto.Changeset{}} =
               Billing.update_stripe_subscription(stripe_subscription, @invalid_attrs)

      assert stripe_subscription == Billing.get_stripe_subscription!(stripe_subscription.id)
    end

    test "delete_stripe_subscription/1 deletes the stripe_subscription" do
      subscription_plan = subscription_plan_fixture()
      stripe_subscription = stripe_subscription_fixture(subscription_plan)

      assert {:ok, %StripeSubscription{}} =
               Billing.delete_stripe_subscription(stripe_subscription)

      assert_raise Ecto.NoResultsError, fn ->
        Billing.get_stripe_subscription!(stripe_subscription.id)
      end
    end

    test "change_stripe_subscription/1 returns a stripe_subscription changeset" do
      subscription_plan = subscription_plan_fixture()
      stripe_subscription = stripe_subscription_fixture(subscription_plan)

      assert %Ecto.Changeset{} = Billing.change_stripe_subscription(stripe_subscription)
    end
  end
end
