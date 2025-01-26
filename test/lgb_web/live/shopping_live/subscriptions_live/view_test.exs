defmodule LgbWeb.ShoppingLive.SubscriptionsLive.ViewTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest
  import Lgb.SubscriptionsFixtures

  describe "subscriptions view" do
    setup [:register_and_log_in_user, :create_subscription_plans]

    test "displays subscription page title", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/shopping/subscriptions")
      assert html =~ "Subscription Plans"
    end

    test "displays subscription plans", %{conn: conn, subscription_plans: plans} do
      {:ok, _view, html} = live(conn, ~p"/shopping/subscriptions")

      for plan <- plans do
        assert html =~ plan.name
        assert html =~ plan.stripe_price_id
        assert html =~ "$#{plan.amount |> Decimal.new() |> Decimal.div(100)}"
      end
    end

    defp create_subscription_plans(_) do
      plans = [
        subscription_plan_fixture(%{name: "Basic Plan", amount: 1000, stripe_price_id: "price_basic123"}),
        subscription_plan_fixture(%{name: "Premium Plan", amount: 2000, stripe_price_id: "price_premium456"})
      ]
      %{subscription_plans: plans}
    end
  end
end
