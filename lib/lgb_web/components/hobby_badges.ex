defmodule LgbWeb.Components.HobbyBadges do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-wrap gap-4">
        <%= for hobby <- @hobbies do %>
          <button
            type="button"
            phx-click="toggle_hobby"
            phx-value-id={hobby.id}
            disabled={@display_only}
            class={["rounded-full px-3 py-1 text-sm transition-all duration-200 ease-in-out", selected_class(hobby, @selected_hobbies)]}
          >
            {hobby.name}
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  defp selected_class(hobby, selected_hobbies) do
    if Enum.any?(selected_hobbies, &(&1.id == hobby.id)) do
      "tag-attribute-cherry-blossom"
    else
      "bg-gray-200 text-gray-700 hover:bg-gray-300 border-2 border-gray-300"
    end
  end

  def handle_event("toggle_hobby", %{"id" => id}, socket) do
    hobby = Enum.find(socket.assigns.hobbies, &(to_string(&1.id) == id))

    updated_hobbies =
      if Enum.any?(socket.assigns.selected_hobbies, &(&1.id == hobby.id)) do
        Enum.reject(socket.assigns.selected_hobbies, &(&1.id == hobby.id))
      else
        [hobby | socket.assigns.selected_hobbies]
      end

    {:noreply, assign(socket, :selected_hobbies, updated_hobbies)}
  end
end
