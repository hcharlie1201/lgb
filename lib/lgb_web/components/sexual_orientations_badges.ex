defmodule LgbWeb.Components.SexualOrientationBadges do
  use Phoenix.LiveComponent

  @limit_selection 3

  @doc """
  Renders a list of selectable sexual orientation buttons.
  
  This function generates a flex container with a button for each sexual orientation provided via the `@sexual_orientations` assign. Each button triggers a "toggle_sexual_orientation" event and applies dynamic styling based on its selection state, as determined by the `@selected_sexual_orientations` assign.
  """
  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div>
      <div class="flex flex-wrap gap-4">
        <%= for sexual_orientation <- @sexual_orientations do %>
          <button
            type="button"
            phx-click="toggle_sexual_orientation"
            phx-value-category={sexual_orientation}
            class={["rounded-full px-3 py-1 text-sm transition-all duration-200 ease-in-out", selected_class(sexual_orientation, @selected_sexual_orientations)]}
          >
            {sexual_orientation}
          </button>
        <% end %>
      </div>
    </div>
    """
  end

  defp selected_class(sexual_orientation, selected_sexual_orientations) do
    if sexual_orientation in selected_sexual_orientations do
      "tag-attribute-sky"
    else
      "bg-gray-200 text-gray-700 hover:bg-gray-300 border-2 border-gray-300"
    end
  end
end
