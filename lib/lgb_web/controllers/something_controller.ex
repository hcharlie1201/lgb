defmodule LgbWeb.SomethingController do
  use LgbWeb, :controller

  def index(conn, _params) do
    blogs = ["Blog 1", "Blog 2"]
    render(conn, :in, blogs: blogs)
  end

  def index2(conn, params) do
    blogs = ["Blog 1", "Blog 2"]
    s = Lgb.Something.add(2,5)
    render(conn, :index2, blogs: blogs, s: s)
  end
end
