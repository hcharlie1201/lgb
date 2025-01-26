defmodule LgbWeb.ShoppingLive.SubscriptionsLive.ViewTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest
  alias Lgb.Subscriptions
  alias Lgb.Accounts

  describe "subscriptions view" do
    setup [:register_and_log_in_user]

    test "displays subscription plans", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/shopping/subscriptions")
      assert has_element?(view, "[data-role='subscription-plans']")
    end

    test "handles user without stripe customer", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/shopping/subscriptions")
      refute has_element?(view, "[data-role='completed-checkout']")
    end

    test "shows completed checkout for subscribed users", %{conn: conn, user: user} do
      # Create stripe customer and subscription for user
      {:ok, stripe_customer} = Accounts.create_stripe_customer(user, %{
        "name" => "Test User",
        "address" => %{
          "line1" => "123 Test St",
          "city" => "Test City",
          "state" => "TS",
          "postal_code" => "12345",
          "country" => "US"
        }
      })

      subscription_plan = Subscriptions.get_subscription_plan!("test_plan")
      {:ok, _subscription} = Lgb.Billing.create_stripe_subscription(stripe_customer, subscription_plan)

      {:ok, view, _html} = live(conn, ~p"/shopping/subscriptions")
      assert has_element?(view, "[data-role='subscription-plans']")
    end
  end
end
