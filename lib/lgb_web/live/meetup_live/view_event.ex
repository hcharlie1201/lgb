defmodule LgbWeb.MeetupLive.ViewEvent do
  use LgbWeb, :live_view

  alias Lgb.Meetups
  alias Lgb.Meetups.{EventComment, EventCommentReply}
  alias LgbWeb.MeetupLive.Handlers.{EventHandlers, ParticipantHandlers}

  def mount(_params, _session, socket) do
    current_profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
    {:ok, assign(socket, :current_profile, current_profile)}
  end

  def handle_params(%{"id" => event_location_uuid}, _url, socket) do
    event_location = Meetups.get_location_by_uuid(event_location_uuid)
    current_profile = socket.assigns.current_profile

    socket =
      socket
      |> assign(:event_location, event_location)
      |> assign(:host, Meetups.get_host(event_location))
      |> assign(:participants, Meetups.list_participants(event_location.id))
      |> assign(:comments, Meetups.list_event_comments(event_location))
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
      |> assign_new(:comment_reply_form, fn ->
        to_form(EventCommentReply.changeset(%EventCommentReply{}, %{}))
      end)

    {:noreply, socket}
  end

  # Comment Likes
  def handle_event("toggle_comment_like", %{"comment_id" => comment_id}, socket) do
    {:noreply, EventHandlers.handle_toggle_comment_like(socket, comment_id)}
  end

  # Add Comment Reply
  def handle_event(
        "add_comment_reply",
        %{"event_comment_reply" => reply_params, "comment_id" => comment_id},
        socket
      ) do
    {:noreply, EventHandlers.handle_add_comment_reply(socket, reply_params, comment_id)}
  end

  # Comment Reply Likes
  def handle_event("toggle_reply_like", %{"reply_id" => reply_id}, socket) do
    {:noreply, EventHandlers.handle_toggle_reply_like(socket, reply_id)}
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

  # Delete Comment Reply Handler
  def handle_event("delete_comment_reply", %{"reply_id" => reply_id}, socket) do
    {:noreply, EventHandlers.handle_delete_comment_reply(socket, reply_id)}
  end
end
