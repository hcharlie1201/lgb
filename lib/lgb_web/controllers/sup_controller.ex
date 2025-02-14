defmodule LgbWeb.SupController do
  use LgbWeb, :controller

  def greet(conn, _params) do
    greets = ["hi", "hey"]
    render(conn, :greetings, greets: greets)
  end

  def greetSomeone(conn, _params) do
    s = Lgb.Supper.greet("Sup biatch", "Hey bitch ass")
    render(conn, :greetSomeone, s: s)
  end
end
