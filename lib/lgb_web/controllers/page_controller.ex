defmodule LgbWeb.PageController do
  use LgbWeb, :controller

  def home(conn, _params) do
    # The home page is often custom made,
    # so skip the default app layout.
    render(conn, :home, bg_color: "bg-red-200")
  end
end
