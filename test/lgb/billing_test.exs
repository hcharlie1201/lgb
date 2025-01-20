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

    test "create_stripe_customer/1 with valid data creates a stripe_customer" do
      valid_attrs = %{customer_id: 42}

      assert {:ok, %StripeCustomer{} = stripe_customer} = Billing.create_stripe_customer(valid_attrs)
      assert stripe_customer.customer_id == 42
    end

    test "create_stripe_customer/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Billing.create_stripe_customer(@invalid_attrs)
    end

    test "update_stripe_customer/2 with valid data updates the stripe_customer" do
      stripe_customer = stripe_customer_fixture()
      update_attrs = %{customer_id: 43}

      assert {:ok, %StripeCustomer{} = stripe_customer} = Billing.update_stripe_customer(stripe_customer, update_attrs)
      assert stripe_customer.customer_id == 43
    end

    test "update_stripe_customer/2 with invalid data returns error changeset" do
      stripe_customer = stripe_customer_fixture()
      assert {:error, %Ecto.Changeset{}} = Billing.update_stripe_customer(stripe_customer, @invalid_attrs)
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
end
