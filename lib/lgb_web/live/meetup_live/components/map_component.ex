defmodule LgbWeb.MeetupLive.Components.MapComponent do
  use Phoenix.Component

  attr :map_id, :string, required: true
  attr :locations, :any, required: true

  def map(assigns) do
    ~H"""
    <div id="map_component" class="h-[calc(100vh-160px)]">
      <div
        phx-update="ignore"
        id={@map_id}
        class="h-full w-full rounded-md"
        phx-hook="MeetupMap"
        data-api-key={System.fetch_env!("GOOGLE_MAPS_API_KEY")}
      />
    </div>
    """
  end
end
