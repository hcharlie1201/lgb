defmodule LgbWeb.Components.ProfilePreview do
  use Phoenix.LiveComponent
  import LgbWeb.CoreComponents
  alias Phoenix.LiveView.JS

  use Phoenix.VerifiedRoutes,
    router: LgbWeb.Router,
    endpoint: LgbWeb.Endpoint,
    statics: ~w(images)

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    current_profile = Lgb.Accounts.User.current_profile(assigns.current_user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(current_profile: current_profile)
     |> assign(uploaded_files: assigns.profile.profile_pictures)
     |> assign(current_index: 0)}
  end

  def render(assigns) do
    ~H"""
    <section
      phx-click={JS.push("redirect_to_profile", target: @myself)}
      class="relative m-1 border-b-2 border-transparent transition-all duration-200 hover:border-blue-300"
    >
      <div :if={@current_profile.id != @profile.id} class="absolute top-2 right-2 z-10">
        <.live_component
          id={@prefix_id <> "starred" <>"#{@profile.uuid}"}
          module={LgbWeb.Components.Favorite}
          current_profile={@current_profile}
          profile={@profile}
        />
      </div>
      <div class="relative">
        <div class="group relative mx-auto w-full max-w-6xl overflow-hidden rounded-md shadow-md">
          <div
            class="relative flex h-96 space-x-4 transition-transform duration-500 ease-in-out"
            style={"transform: translateX(-#{@current_index * 100}%)"}
          >
            <div
              :for={uploaded_file <- @uploaded_files}
              class="group relative w-full flex-shrink-0"
              style="width: 100%"
            >
              <img
                src={
                  Lgb.Profiles.ProfilePictureUploader.url(
                    {uploaded_file.image, uploaded_file},
                    :original,
                    signed: true
                  )
                }
                class="h-full w-full rounded-lg object-cover"
              />
            </div>
            <div
              :if={length(@uploaded_files) == 0}
              class="group relative w-full flex-shrink-0"
              style="width: 100%"
            >
              <div class="flex h-full w-full items-center justify-center rounded-lg bg-gray-200">
                <svg
                  xmlns="http://www.w3.org/2000/svg"
                  class="h-32 w-32 text-gray-400"
                  viewBox="0 0 20 20"
                  fill="currentColor"
                >
                  <path
                    fill-rule="evenodd"
                    d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"
                    clip-rule="evenodd"
                  />
                </svg>
              </div>
            </div>
          </div>

          <div class="group">
            <!-- Previous Button -->
            <button
              :if={@current_index > 0}
              phx-click={JS.push("prev", target: @myself)}
              class="bg-white/30 absolute top-1/2 left-4 -translate-y-1/2 transform rounded-full p-3 text-gray-800 opacity-0 shadow-md transition-opacity duration-200 hover:bg-purple-200 group-hover:opacity-100"
            >
              ←
            </button>
            
    <!-- Next Button -->
            <button
              :if={@current_index < length(@uploaded_files) - 1}
              phx-click={JS.push("next", target: @myself)}
              class="bg-white/30 absolute top-1/2 right-4 -translate-y-1/2 transform rounded-full p-3 text-gray-800 opacity-0 shadow-md transition-opacity duration-200 hover:bg-purple-200 group-hover:opacity-100"
            >
              →
            </button>
          </div>
          
    <!-- Indicators -->
          <div
            :if={length(@uploaded_files) > 0}
            class="absolute bottom-4 left-1/2 flex -translate-x-1/2 transform space-x-2"
          >
            <%= for {_uploaded_file, index} <- Enum.with_index(@uploaded_files) do %>
              <button class={"#{if index == @current_index, do: "bg-colorSecondary", else: "bg-purple-200"} h-3 w-3 rounded-full opacity-0 transition-colors duration-200 group-hover:opacity-100"}>
              </button>
            <% end %>
          </div>
        </div>
        <div class="bg-gray-400/10 absolute right-0 bottom-0 left-0 rounded-b-lg p-4">
          <.name_with_online_activity profile={@profile} primary={false} />
        </div>
      </div>
      <div class="space-y-2 p-4">
        <div class="grid grid-cols-2 gap-3 text-sm">
          <div class="flex items-center gap-2 text-gray-600">
            <.icon name="hero-rectangle-stack" class="h-4 w-4" />
            <span>{Lgb.Profiles.display_height(@profile.height_cm)}</span>
          </div>
          <div class="flex items-center gap-2 text-gray-600">
            <.icon name="hero-scale-solid" class="h-4 w-4" />
            <span>{Lgb.Profiles.display_weight(@profile.weight_lb)}</span>
          </div>
          <div class="flex items-center gap-2 text-gray-600">
            <.icon name="hero-cake-solid" class="h-4 w-4" />
            <span>{@profile.age} years</span>
          </div>
          <div class="flex items-center gap-2 text-gray-600">
            <.icon name="hero-map-pin-solid" class="h-4 w-4" />
            <span>{Lgb.Profiles.display_distance(@profile.distance)} miles away</span>
          </div>
        </div>
      </div>
    </section>
    """
  end

  def handle_event("next", _, socket) do
    current_index = rem(socket.assigns.current_index + 1, length(socket.assigns.uploaded_files))
    {:noreply, assign(socket, current_index: current_index)}
  end

  def handle_event("prev", _, socket) do
    current_index =
      rem(
        socket.assigns.current_index - 1 + length(socket.assigns.uploaded_files),
        length(socket.assigns.uploaded_files)
      )

    {:noreply, assign(socket, current_index: current_index)}
  end

  def handle_event("redirect_to_profile", _, socket) do
    {:noreply, push_navigate(socket, to: "/profiles/#{socket.assigns.profile.uuid}")}
  end
end
