defmodule LgbWeb.Components.Carousel do
  use Phoenix.LiveComponent
  alias Phoenix.LiveView.JS

  def mount(socket) do
    {:ok, assign(socket, current_index: 0, class: "")}
  end

  def render(assigns) do
    ~H"""
    <div
      id={"carousel-#{@id}"}
      class={["group relative mx-auto w-full max-w-6xl overflow-hidden rounded-md shadow-md", @class]}
    >
      <!-- Carousel Container -->
      <div
        class="relative flex h-96 space-x-4 transition-transform duration-500 ease-in-out"
        style={"transform: translateX(-#{@current_index * (100 / @length)}%)"}
      >
        <%= for uploaded_file <- @uploaded_files do %>
          <div class="w-full flex-shrink-0" style={"width: #{100 / @length}%"}>
            <img
              src={
                Lgb.Profiles.ProfilePictureUploader.url(
                  {uploaded_file.image, uploaded_file},
                  :original,
                  signed: true
                )
              }
              alt="Carousel Image"
              class="h-full w-full rounded-lg object-cover"
            />
          </div>
        <% end %>
      </div>

      <div class="group">
        <!-- Previous Button -->
        <%= if @current_index > 0 and length(@uploaded_files) > 0 do %>
          <button
            phx-click={JS.push("prev", target: @myself)}
            class="bg-white/30 absolute top-1/2 left-4 -translate-y-1/2 transform rounded-full p-3 text-gray-800 opacity-0 shadow-md transition-opacity duration-200 hover:bg-purple-200 group-hover:opacity-100"
          >
            ←
          </button>
        <% end %>
        
    <!-- Next Button -->
        <%= if @current_index < length(@uploaded_files) - 1 and length(@uploaded_files) > 0 do %>
          <button
            phx-click={JS.push("next", target: @myself)}
            class="bg-white/30 absolute top-1/2 right-4 -translate-y-1/2 transform rounded-full p-3 text-gray-800 opacity-0 shadow-md transition-opacity duration-200 hover:bg-purple-200 group-hover:opacity-100"
          >
            →
          </button>
        <% end %>
      </div>
      
    <!-- Indicators -->
      <div class="absolute bottom-4 left-1/2 flex -translate-x-1/2 transform space-x-2">
        <%= for {_uploaded_file, index} <- Enum.with_index(@uploaded_files) do %>
          <button class={"#{if index == @current_index, do: "bg-colorSecondary", else: "bg-purple-200"} h-3 w-3 rounded-full opacity-0 transition-colors duration-200 group-hover:opacity-100"}>
          </button>
        <% end %>
      </div>
    </div>
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
end
