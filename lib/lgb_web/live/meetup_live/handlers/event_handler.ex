defmodule LgbWeb.MeetupLive.Handlers.EventHandlers do
  import Phoenix.Component
  import Phoenix.LiveView

  alias Lgb.Meetups

  # Comment Likes
  def handle_toggle_comment_like(socket, comment_id) do
    current_profile = socket.assigns.current_profile

    case Meetups.toggle_comment_like(comment_id, current_profile.id) do
      {:ok, updated_comment} ->
        socket
        |> update(:comments, fn comments ->
          Enum.map(comments, fn comment ->
            if comment.id == updated_comment.id, do: updated_comment, else: comment
          end)
        end)

      {:error, _} ->
        put_flash(socket, :error, "Could not like comment")
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
        |> update(:comments, fn comments ->
          Enum.map(comments, fn comment ->
            if comment.id == comment_id do
              # Assuming we want to add the reply to the comment's replies
              updated_replies = [reply | comment.replies || []]
              Map.put(comment, :replies, updated_replies)
            else
              comment
            end
          end)
        end)

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Failed to add reply")
        |> assign(:comment_reply_form, to_form(changeset))
    end
  end

  # Comment Reply Likes
  def handle_toggle_reply_like(socket, reply_id) do
    current_profile = socket.assigns.current_profile

    case Meetups.toggle_reply_like(reply_id, current_profile.id) do
      {:ok, updated_reply} ->
        socket
        |> update(:comments, fn comments ->
          Enum.map(comments, fn comment ->
            updated_replies =
              Enum.map(comment.replies || [], fn reply ->
                if reply.id == updated_reply.id, do: updated_reply, else: reply
              end)

            Map.put(comment, :replies, updated_replies)
          end)
        end)

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
        |> update(:comments, fn comments -> [comment | comments] end)

      {:error, changeset} ->
        socket
        |> put_flash(:error, "Failed to add comment")
        |> assign(:comment_form, to_form(changeset))
    end
  end

  # Delete Comment Handler
  def handle_delete_comment(socket, comment_id) do
    current_profile = socket.assigns.current_profile

    case Meetups.delete_event_comment(comment_id, current_profile.id) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "Comment deleted successfully")
        |> update(:comments, fn comments ->
          Enum.reject(comments, fn comment -> comment.id == comment_id end)
        end)

      {:error, reason} ->
        socket
        |> put_flash(:error, reason)
    end
  end

  # Delete Comment Reply Handler
  def handle_delete_comment_reply(socket, reply_id) do
    current_profile = socket.assigns.current_profile

    case Meetups.delete_comment_reply(reply_id, current_profile.id) do
      {:ok, _} ->
        socket
        |> put_flash(:info, "Reply deleted successfully")
        |> update(:comments, fn comments ->
          Enum.map(comments, fn comment ->
            updated_replies =
              Enum.reject(comment.replies || [], fn reply -> reply.id == reply_id end)

            Map.put(comment, :replies, updated_replies)
          end)
        end)

      {:error, reason} ->
        socket
        |> put_flash(:error, reason)
    end
  end
end
