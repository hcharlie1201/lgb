defmodule LgbWeb.Components.DatingGoalBadges do
  use Phoenix.LiveComponent

  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-wrap gap-4">
        <%= for goal <- @dating_goals do %>
          <button
            type="button"
            phx-click="toggle_goal"
            phx-value-id={goal.id}
            class={["rounded-full px-3 py-1 text-sm transition-all duration-200 ease-in-out", selected_class(goal, @selected_goals)]}
          >
            {goal.name}
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  defp selected_class(goal, selected_goals) do
    if Enum.any?(selected_goals, &(&1.id == goal.id)) do
      "tag-attribute"
    else
      "bg-gray-200 text-gray-700 hover:bg-gray-300 border-2 border-gray-300"
    end
  end

  def handle_event("toggle_goal", %{"id" => id}, socket) do
    goal = Enum.find(socket.assigns.dating_goals, &(to_string(&1.id) == id))

    updated_goals =
      if Enum.any?(socket.assigns.selected_goals, &(&1.id == goal.id)) do
        Enum.reject(socket.assigns.selected_goals, &(&1.id == goal.id))
      else
        if length(socket.assigns.selected_goals) < 2 do
          [goal | socket.assigns.selected_goals]
        else
          socket.assigns.selected_goals
        end
      end

    {:noreply, assign(socket, :selected_goals, updated_goals)}
  end
end
