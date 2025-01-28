defmodule LgbWeb.DashboardLive do
  use LgbWeb, :live_view

  def render(assigns) do
    ~H"""
    <.page_align>
      <.header>
        Hi welcome to BiBi. This site is a meeting place for bisexual men and women who are looking for genuine connections,
        meaningful relationships, and long-term love. Whether you’re seeking a deep emotional bond or a
        committed partnership, this platform offers a welcoming space to connect, chat, and build something real – and it’s free!
      </.header>
      <br />
      <.header>
        Global Users
      </.header>
      <.header>
        New users
      </.header>
      <.header>
        Members that viewed you
      </.header>
      <.header>
        Members that heart you
      </.header>
    </.page_align>
    """
  end

  def mount(_params, _session, socket) do
    stripe_customer = Lgb.Accounts.get_stripe_customer(socket.assigns.current_user)
    socket = assign(socket, stripe_customer: stripe_customer)
    {:ok, socket}
  end
end
