defmodule LgbWeb.Components.ProfilePreview do
  use Phoenix.LiveComponent

  use Phoenix.VerifiedRoutes,
    router: LgbWeb.Router,
    endpoint: LgbWeb.Endpoint,
    statics: ~w(images)

  import LgbWeb.CoreComponents

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    current_profile = Lgb.Accounts.User.current_profile(assigns.current_user)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(current_profile: current_profile)}
  end

  def render(assigns) do
    ~H"""
    <section class="relative m-1 border-b-2 border-transparent transition-all duration-200 hover:border-blue-300">
      <div :if={@current_profile.id != @profile.id} class="absolute top-2 right-2 z-10">
        <.live_component
          id={@prefix_id <> "starred" <>"#{@profile.uuid}"}
          module={LgbWeb.Components.Favorite}
          current_profile={@current_profile}
          profile={@profile}
        />
      </div>
      <div class="relative">
        <.live_component
          id={@prefix_id <> "#{@profile.uuid}"}
          module={LgbWeb.Components.Carousel}
          uploaded_files={@profile.profile_pictures}
          length={1}
        />
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
end
