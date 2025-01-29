# lib/my_app_web/components/carousel.ex

defmodule MyAppWeb.Components.Carousel do
  use Phoenix.Component
  alias Phoenix.LiveView.JS

  def carousel(assigns) do
    ~H"""
    <div class="relative w-full max-w-6xl mx-auto overflow-hidden rounded-lg shadow-lg">
      <!-- Carousel Container -->
      <div
        class="relative h-96 flex space-x-4 transition-transform duration-500 ease-in-out"
        style={"transform: translateX(-#{@current_index * 33.33}%)"}
      >
        <%= for uploaded_file <- @uploaded_files do %>
          <div class="flex-shrink-0 w-1/3 h-full">
            <img
              src={
                Lgb.Profiles.ProfilePictureUploader.url(
                  {uploaded_file.image, uploaded_file},
                  :original,
                  signed: true
                )
              }
              alt="Carousel Image"
              class="w-full h-full object-cover rounded-lg"
            />
          </div>
        <% end %>
      </div>
      
    <!-- Previous Button -->
      <button
        phx-click="prev"
        class="absolute left-4 top-1/2 transform -translate-y-1/2 bg-white/30 hover:bg-white/50 text-gray-800 rounded-full p-3 shadow-md transition-colors duration-200"
      >
        ←
      </button>
      
    <!-- Next Button -->
      <button
        phx-click="next"
        class="absolute right-4 top-1/2 transform -translate-y-1/2 bg-white/30 hover:bg-white/50 text-gray-800 rounded-full p-3 shadow-md transition-colors duration-200"
      >
        →
      </button>
      
    <!-- Indicators -->
      <div class="absolute bottom-4 left-1/2 transform -translate-x-1/2 flex space-x-2">
        <%= for {_uploaded_file, index} <- Enum.with_index(@uploaded_files) do %>
          <button
            phx-click={JS.push("select", value: %{index: index})}
            class={"w-3 h-3 rounded-full #{if index == @current_index, do: "bg-white", else: "bg-white/50"} transition-colors duration-200"}
          >
          </button>
        <% end %>
      </div>
    </div>
    """
  end
end
