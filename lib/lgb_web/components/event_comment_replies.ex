defmodule LgbWeb.Components.EventCommentReplies do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS
  alias Lgb.Meetups.{EventCommentReply, EventComment}
  alias LgbWeb.MeetupLive.Handlers.{EventHandlers, ParticipantHandlers}
  require Logger

  def mount(socket) do
    {:ok, socket |> stream_configure(:replies, dom_id: fn reply -> "reply-#{reply.id}" end)}
  end

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:comment_reply_form, fn ->
       to_form(EventCommentReply.changeset(%EventCommentReply{}, %{}))
     end)
     |> stream(:replies, assigns.replies)}
  end

  def render(assigns) do
    ~H"""
    <section class="mt-4 space-y-4 border-l-2 border-gray-200 pl-6">
      <div id="event_comment_replies" phx-update="stream">
        <div :for={{dom_id, reply} <- @streams.replies} id={dom_id} class="rounded-lg bg-white p-3">
          <!-- Reply Header -->
          <div class="flex justify-between">
            <div class="flex items-center">
              <div class="h-8 w-8 flex-shrink-0">
                <img
                  class="h-8 w-8 rounded-full"
                  src={
                    if reply.profile.first_picture do
                      Lgb.Profiles.ProfilePictureUploader.url(
                        {reply.profile.first_picture.image, reply.profile.first_picture},
                        :original,
                        signed: true
                      )
                    else
                      "https://lgb-public.s3.us-west-2.amazonaws.com/static/empty-profile.jpg"
                    end
                  }
                  alt={reply.profile.handle}
                />
              </div>
              <div class="ml-3">
                <p class="text-sm font-medium text-gray-900">
                  {reply.profile.handle}
                </p>
                <p class="text-xs text-gray-500">
                  {Calendar.strftime(reply.inserted_at, "%B %d, %Y at %I:%M %p")}
                </p>
              </div>
            </div>
            
    <!-- Delete Reply Button (only for reply owner) -->
            <button
              :if={@current_profile.id == reply.profile_id}
              phx-click="delete_comment_reply"
              phx-target={@myself}
              phx-value-reply_id={reply.id}
              class="text-gray-400 hover:text-gray-600"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="h-4 w-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16"
                />
              </svg>
            </button>
          </div>
          
    <!-- Reply Content -->
          <div class="mt-1 text-sm text-gray-700">
            <p>{reply.content}</p>
          </div>
          
    <!-- Reply Like Button -->
          <div class="mt-1">
            <button
              phx-click="toggle_reply_like"
              phx-value-reply_id={reply.id}
              phx-target={@myself}
              class="flex items-center text-xs text-gray-500 hover:text-indigo-600"
            >
              <svg
                xmlns="http://www.w3.org/2000/svg"
                class="mr-1 h-4 w-4"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
              >
                <path
                  stroke-linecap="round"
                  stroke-linejoin="round"
                  stroke-width="2"
                  d="M14 10h4.764a2 2 0 011.789 2.894l-3.5 7A2 2 0 0115.263 21h-4.017c-.163 0-.326-.02-.485-.06L7 20m7-10V5a2 2 0 00-2-2h-.095c-.5 0-.905.405-.905.905 0 .714-.211 1.412-.608 2.006L7 11v9m7-10h-2M7 20H5a2 2 0 01-2-2v-6a2 2 0 012-2h2.5"
                />
              </svg>
              <span>
                {length(reply.likes)} {if length(reply.likes) == 1,
                  do: "like",
                  else: "likes"}
              </span>
            </button>
          </div>
        </div>
      </div>
      
    <!-- Reply Form (hidden by default, shown with JS) -->
      <div id={"reply-form-#{@comment.id}"} class="mt-4 hidden pl-6">
        <.form
          for={@comment_reply_form}
          phx-submit="add_comment_reply"
          phx-value-comment_id={@comment.id}
          phx-target={@myself}
          class="space-y-3"
        >
          <div>
            <label
              for={"reply-content-#{@comment.id}"}
              class="sr-only block text-sm font-medium text-gray-700"
            >
              Your reply
            </label>
            <div class="mt-1">
              <textarea
                id={"reply-content-#{@comment.id}"}
                name="event_comment_reply[content]"
                rows="2"
                class="block w-full rounded-md border-gray-300 shadow-sm focus:border-indigo-500 focus:ring-indigo-500 sm:text-sm"
                placeholder="Add your reply..."
              ></textarea>
            </div>
          </div>
          <div class="flex justify-end space-x-2">
            <button
              type="button"
              phx-click={JS.hide(to: "#reply-form-#{@comment.id}")}
              class="primary-button"
            >
              Cancel
            </button>
            <button type="submit" class="primary-button">
              Post Reply
            </button>
          </div>
        </.form>
      </div>
    </section>
    """
  end

  # Add Comment Reply
  def handle_event(
        "add_comment_reply",
        %{"event_comment_reply" => reply_params, "comment_id" => comment_id},
        socket
      ) do
    {:noreply, EventHandlers.handle_add_comment_reply(socket, reply_params, comment_id)}
  end

  # Delete Comment Reply Handler
  def handle_event("delete_comment_reply", %{"reply_id" => reply_id}, socket) do
    {:noreply, EventHandlers.handle_delete_comment_reply(socket, reply_id)}
  end

  # Comment Reply Likes
  def handle_event("toggle_reply_like", %{"reply_id" => reply_id}, socket) do
    {:noreply, EventHandlers.handle_toggle_reply_like(socket, reply_id)}
  end
end
