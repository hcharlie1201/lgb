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

  def within_minutes?(datetime, minutes) do
    DateTime.diff(DateTime.utc_now(), datetime) < minutes * 60
  end

  def within_hours?(datetime, hours) do
    DateTime.diff(DateTime.utc_now(), datetime) < hours * 3600
  end

  def format_hours_ago(datetime) do
    minutes = DateTime.diff(DateTime.utc_now(), datetime) |> div(60)

    cond do
      minutes < 1 -> "active now"
      minutes < 60 -> "active #{minutes}m ago"
      minutes < 1440 -> "ctive #{div(minutes, 60)}h ago"
      true -> "active today"
    end
  end
end
