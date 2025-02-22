defmodule LgbWeb.Geolocation do
  use Phoenix.LiveComponent
  require Logger

  def mount(socket) do
    {:ok, socket}
  end

  def update(assigns, socket) do
    socket = assign(socket, assigns)
    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <div id={@id} phx-hook="Geolocation" class="hidden"></div>
    """
  end

  def handle_event(
        "geolocation-success",
        %{"latitude" => lat, "longitude" => lng},
        socket
      ) do
    point = %Geo.Point{coordinates: {lat, lng}, srid: 4326}
    current_user = socket.assigns.current_user
    profile = Lgb.Accounts.User.current_profile(current_user)

    should_update =
      cond do
        is_nil(profile.geolocation) -> true
        significant_location_change?(profile.geolocation, point) -> true
        true -> false
      end

    if should_update do
      case Lgb.Profiles.update_profile(profile, %{geolocation: point}) do
        {:ok, _updated_profile} ->
          {:noreply, socket}

        {:error, _changeset} ->
          Logger.error("Failed to update location for user: #{current_user.uuid}")
          {:noreply, socket}
      end
    else
      {:noreply, socket}
    end
  end

  def handle_event("geolocation-error", %{"message" => message}, socket) do
    Logger.error(
      "Unable to update geolocation: user: #{socket.assigns.current_user.uuid} - #{message}"
    )

    {:noreply, socket}
  end

  defp significant_location_change?(old_point, new_point) do
    # Extract coordinates
    {old_lng, old_lat} = old_point.coordinates
    {new_lng, new_lat} = new_point.coordinates

    lat_diff = new_lat - old_lat
    lng_diff = new_lng - old_lng

    dist_approx =
      :math.sqrt(
        :math.pow(lat_diff * 111_000, 2) +
          :math.pow(lng_diff * 111_000 * :math.cos(new_lat * :math.pi() / 180), 2)
      )

    dist_approx > 100
  end
end
