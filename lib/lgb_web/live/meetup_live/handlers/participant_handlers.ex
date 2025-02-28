defmodule LgbWeb.MeetupLive.Handlers.ParticipantHandlers do
  @moduledoc """
  Handlers for participant management in the Meetup LiveView.
  """
  import Phoenix.LiveView
  import Phoenix.Component
  alias Lgb.Meetups

  @doc """
  Handles joining a meetup event.
  """
  def handle_join_meetup(location_id, socket) do
    # Get the current user's profile
    current_profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
    location_id = String.to_integer(location_id)

    # Join the meetup
    case Meetups.join_meetup(location_id, current_profile.id) do
      {:ok, _participant} -> handle_successful_join(socket)
      {:error, reason} -> handle_join_error(reason, socket)
    end
  end

  @doc """
  Handles leaving a meetup event.
  """
  def handle_leave_meetup(location_id, socket) do
    # Get the current user's profile
    current_profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
    location_id = String.to_integer(location_id)

    # Leave the meetup
    case Meetups.leave_meetup(location_id, current_profile.id) do
      {:ok, _} -> handle_successful_leave(socket)
      {:error, reason} -> handle_leave_error(reason, socket)
    end
  end

  # Private functions

  defp handle_successful_join(socket) do
    # Refresh the locations data after successful join
    Process.send_after(self(), :load_locations, 100)

    {:noreply,
     socket
     |> assign(:show_location_modal, false)
     |> put_flash(:info, "You've successfully joined this meetup!")}
  end

  defp handle_successful_leave(socket) do
    # Refresh the locations data after successful leave
    Process.send_after(self(), :load_locations, 100)

    {:noreply,
     socket
     |> assign(:show_location_modal, false)
     |> put_flash(:info, "You've left this meetup.")}
  end

  defp handle_join_error(:already_participating, socket) do
    {:noreply, socket |> put_flash(:info, "You're already participating in this meetup.")}
  end

  defp handle_join_error(:event_full, socket) do
    {:noreply, socket |> put_flash(:error, "This meetup is already at maximum capacity.")}
  end

  defp handle_join_error(_other, socket) do
    {:noreply, socket |> put_flash(:error, "Error joining the meetup. Please try again.")}
  end

  defp handle_leave_error(:not_participating, socket) do
    {:noreply, socket |> put_flash(:info, "You're not participating in this meetup.")}
  end

  defp handle_leave_error(_other, socket) do
    {:noreply, socket |> put_flash(:error, "Error leaving the meetup. Please try again.")}
  end
end
