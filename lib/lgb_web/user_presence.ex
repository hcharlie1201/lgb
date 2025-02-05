defmodule LgbWeb.UserPresence do
  alias LgbWeb.Presence
  use LgbWeb, :live_view

  def on_mount(:track, _params, _session, socket) do
    if connected?(socket) do
      Presence.track_user(
        socket.assigns.current_user.id,
        "users",
        socket.assigns.current_user
      )

      Lgb.Accounts.update_user_last_login_at(socket.assigns.current_user)
      # Subscribe to presence updates
      Presence.subscribe("users")
    end

    {:cont, socket}
  end
end
