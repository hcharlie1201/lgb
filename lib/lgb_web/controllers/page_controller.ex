defmodule LgbWeb.PageController do
  use LgbWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, bg_color: "bg-red-200")
  end

  def products(conn, _param) do
    render(conn, :product)
  end

  def features(conn, _param) do
    render(conn, :feature)
  end

  def blogs(conn, _param) do
    render(conn, :blog)
  end

  def community(conn, _param) do
    render(conn, :community)
  end

  def pricing(conn, _param) do
    render(conn, :pricing)
  end
end
