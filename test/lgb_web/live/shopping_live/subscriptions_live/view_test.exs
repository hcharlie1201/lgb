defmodule LgbWeb.ShoppingLive.SubscriptionsLive.ViewTest do
  use LgbWeb.ConnCase
  import Phoenix.LiveViewTest

  describe "subscriptions view" do
    setup [:register_and_log_in_user]

    test "displays subscription page title", %{conn: conn} do
      {:ok, _view, html} = live(conn, ~p"/shopping/subscriptions")
      assert html =~ "Subscription Plans"
    end
  end
end
