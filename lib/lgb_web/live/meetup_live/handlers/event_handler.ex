defmodule LgbWeb.MeetupLive.Handlers.EventHandlers do
  import Phoenix.Component
  import Phoenix.LiveView

  alias Lgb.Meetups
  alias Lgb.Meetups.EventComment

  # Comment Likes
  def handle_toggle_comment_like(socket, comment_id) do
    current_profile = socket.assigns.current_profile

    case Meetups.toggle_comment_like(comment_id, current_profile.id) do
      {:ok, updated_comment} ->
        socket
        |> stream_insert(:comments, updated_comment)

      {:error, _} ->
        put_flash(socket, :error, "Could not like comment")
    end
  end

  # Comment Reply Likes
  def handle_toggle_reply_like(socket, reply_id) do
    current_profile = socket.assigns.current_profile

    case Meetups.toggle_reply_like(reply_id, current_profile.id) do
      {:ok, updated_reply} ->
        socket
        |> stream_insert(:replies, updated_reply)

      {:error, _} ->
        put_flash(socket, :error, "Could not like reply")
    end
  end

  # Add Comment Handler
  def handle_add_comment(socket, comment_params) do
    current_profile = socket.assigns.current_profile
    event_location = socket.assigns.event_location

    comment_params =
      comment_params
      |> Map.put("event_location_id", event_location.id)
      |> Map.put("profile_id", current_profile.id)

    case Meetups.create_event_comment(comment_params) do
      {:ok, comment} ->
        socket
        |> put_flash(:info, "Comment added successfully")
        |> stream_insert(:comments, comment, at: 0)
        |> assign(
          :comment_form,
          to_form(EventComment.changeset(%EventComment{}, %{}))
        )

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Failed to add comment")
        |> assign(:comment_form, to_form(changeset))
    end
  end

  # Add Comment Reply
  def handle_add_comment_reply(socket, reply_params, comment_id) do
    current_profile = socket.assigns.current_profile

    reply_params =
      reply_params
      |> Map.put("event_comment_id", comment_id)
      |> Map.put("profile_id", current_profile.id)

    case Meetups.create_comment_reply(reply_params) do
      {:ok, reply} ->
        socket
        |> put_flash(:info, "Reply added successfully")
        |> stream_insert(:replies, reply)

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Failed to add reply")
        |> assign(:comment_reply_form, to_form(changeset))
    end
  end

  # Delete Comment Handler
  def handle_delete_comment(socket, comment_id) do
    current_profile = socket.assigns.current_profile

    case Meetups.delete_event_comment(comment_id, current_profile.id) do
      {:ok, comment} ->
        socket
        |> put_flash(:info, "Comment deleted successfully")
        |> stream_delete(:comments, comment)

      {:error, reason} ->
        socket
        |> put_flash(:error, reason)
    end
  end

  # Delete Comment Reply Handler
  def handle_delete_comment_reply(socket, reply_id) do
    current_profile = socket.assigns.current_profile

    case Meetups.delete_comment_reply(reply_id, current_profile.id) do
      {:ok, reply} ->
        socket
        |> put_flash(:info, "Reply deleted successfully")
        |> stream_delete(:replies, reply)

      {:error, reason} ->
        socket
        |> put_flash(:error, reason)
    end
  end
end
