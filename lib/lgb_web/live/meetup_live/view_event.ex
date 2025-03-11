defmodule LgbWeb.MeetupLive.ViewEvent do
  use LgbWeb, :live_view

  alias Lgb.Meetups
  alias Lgb.Meetups.EventComment
  alias LgbWeb.MeetupLive.Handlers.{EventHandlers, ParticipantHandlers}

  def mount(_params, _session, socket) do
    current_profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)

    {:ok,
     socket
     |> assign(:current_profile, current_profile)
     |> stream_configure(:comments, dom_id: fn comment -> "comment-#{comment.id}" end)}
  end

  def handle_params(%{"id" => event_location_uuid}, _url, socket) do
    event_location = Meetups.get_location_by_uuid(event_location_uuid)
    current_profile = socket.assigns.current_profile

    socket =
      socket
      |> assign(:event_location, event_location)
      |> assign(:host, Meetups.get_host(event_location))
      |> assign(:participants, Meetups.list_participants(event_location.id))
      |> stream(:comments, Meetups.list_event_comments(event_location))
      |> assign(:is_host, event_location.creator_id == current_profile.id)
      |> assign(
        :user_participation_status,
        Meetups.get_user_participation_status(event_location, current_profile)
      )
      |> assign_new(:comment_form, fn ->
        to_form(
          EventComment.changeset(%EventComment{}, %{
            event_location_id: event_location.id,
            profile_id: current_profile.id
          })
        )
      end)

    {:noreply, socket}
  end

  # Comment Likes
  def handle_event("toggle_comment_like", %{"comment_id" => comment_id}, socket) do
    {:noreply, EventHandlers.handle_toggle_comment_like(socket, comment_id)}
  end

  # Attend Event Handler
  def handle_event("attend_event", _, socket) do
    ParticipantHandlers.handle_join_meetup(
      Integer.to_string(socket.assigns.event_location.id),
      socket
    )
  end

  # Leave Event Handler
  def handle_event("leave_event", _, socket) do
    ParticipantHandlers.handle_leave_meetup(
      Integer.to_string(socket.assigns.event_location.id),
      socket
    )
  end

  # Add Comment Handler
  def handle_event("add_comment", %{"event_comment" => comment_params}, socket) do
    {:noreply, EventHandlers.handle_add_comment(socket, comment_params)}
  end

  # Delete Comment Handler
  def handle_event("delete_comment", %{"comment_id" => comment_id}, socket) do
    {:noreply, EventHandlers.handle_delete_comment(socket, comment_id)}
  end
end
