defmodule LgbWeb.DashboardLiveTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest

  setup :register_and_log_in_user

  describe "Dashboard" do
    test "renders navigation links when logged in", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      assert has_element?(view, "a[href='/profiles/current']", "Profile")
      assert has_element?(view, "a[href='/profiles']", "Search")
      assert has_element?(view, "a[href='/conversations']", "Inbox")
      assert has_element?(view, "a[href='/chat_rooms']", "Chatroom")
      assert has_element?(view, "a[href='/shopping/subscriptions']", "Premium")
      assert has_element?(view, "a[href='/account']", "Account")
    end

    test "does not show My Account link without stripe customer", %{conn: conn} do
      {:ok, view, _html} = live(conn, ~p"/dashboard")

      refute has_element?(view, "a[href='/account']", "My Account")
    end

    test "shows My Account link with stripe customer", %{conn: conn, user: user} do
      # Create a stripe customer for the user
      {:ok, _stripe_customer} =
        Lgb.Billing.create_stripe_customer(user, %{
          customer_id: "cus_test123",
          user_id: user.id
        })

      {:ok, view, _html} = live(conn, ~p"/dashboard")

      assert has_element?(view, "a[href='/account']", "Account")
    end
  end
end
