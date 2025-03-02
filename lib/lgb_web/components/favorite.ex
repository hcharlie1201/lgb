defmodule LgbWeb.Components.Favorite do
  use Phoenix.LiveComponent
  require Logger

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    is_starred = Lgb.Profiles.profile_starred?(assigns.current_profile.id, assigns.profile.id)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(is_starred: is_starred)}
  end

  def render(assigns) do
    ~H"""
    <div>
      <%= if @current_profile.id != @profile.id do %>
        <button
          phx-click="toggle_star"
          phx-target={@myself}
          class="bg-black/10 rounded-full p-1.5 hover:bg-black/20"
        >
          <div class="group">
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class={"#{if @is_starred, do: "hidden", else: "block group-hover:hidden"} size-6 text-colorSecondary"}
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="M11.48 3.499a.562.562 0 0 1 1.04 0l2.125 5.111a.563.563 0 0 0 .475.345l5.518.442c.499.04.701.663.321.988l-4.204 3.602a.563.563 0 0 0-.182.557l1.285 5.385a.562.562 0 0 1-.84.61l-4.725-2.885a.562.562 0 0 0-.586 0L6.982 20.54a.562.562 0 0 1-.84-.61l1.285-5.386a.562.562 0 0 0-.182-.557l-4.204-3.602a.562.562 0 0 1 .321-.988l5.518-.442a.563.563 0 0 0 .475-.345L11.48 3.5Z"
              />
            </svg>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              viewBox="0 0 24 24"
              fill="currentColor"
              class={"#{if @is_starred, do: "block", else: "hidden group-hover:block"} size-6 text-colorSecondary"}
            >
              <path
                fill-rule="evenodd"
                d="M10.788 3.21c.448-1.077 1.976-1.077 2.424 0l2.082 5.006 5.404.434c1.164.093 1.636 1.545.749 2.305l-4.117 3.527 1.257 5.273c.271 1.136-.964 2.033-1.96 1.425L12 18.354 7.373 21.18c-.996.608-2.231-.29-1.96-1.425l1.257-5.273-4.117-3.527c-.887-.76-.415-2.212.749-2.305l5.404-.434 2.082-5.005Z"
                clip-rule="evenodd"
              />
            </svg>
          </div>
        </button>
      <% end %>
    </div>
    """
  end

  def handle_event("toggle_star", _params, socket) do
    current_profile = socket.assigns.current_profile
    profile = socket.assigns.profile

    case Lgb.Profiles.toggle_star(current_profile.id, profile.id) do
      {:ok, _starred} ->
        if socket.assigns.is_starred do
          # https://elixirforum.com/t/send-event-from-live-component-to-parent-live-view/41370
          send(self(), {:remove_profile, profile})
        end

        {:noreply, assign(socket, :is_starred, !socket.assigns.is_starred)}

      {:error, _} ->
        {:noreply, socket}
    end
  end
end
