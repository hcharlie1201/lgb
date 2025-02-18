defmodule LgbWeb.ProfileLive.Results do
  alias Lgb.Profiles.Profile
  alias Lgb.Profiles
  use LgbWeb, :live_view

  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}))}
  end

  def handle_params(params, _uri, socket) do
    profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)

    # Build the query with location if provided
    query = build_profile_query(profile, params)

    case Flop.validate_and_run(query, params, for: Profile) do
      {:ok, {profiles, metas}} ->
        {:noreply,
         socket
         |> assign(:profiles, profiles)
         |> assign(:metas, metas)
         |> assign(:location_params, build_location_params(params))}

      {:error, _} ->
        {:noreply, assign(socket, profiles: [], metas: nil)}
    end
  end

  def handle_event("goto", %{"page" => page}, socket) do
    flop = %{socket.assigns.metas.flop | page: page}
    metas = %{socket.assigns.metas | flop: flop}

    path = build_paginated_path(metas, socket.assigns.location_params)
    {:noreply, push_patch(socket, to: path)}
  end

  def handle_event("next", _params, socket) do
    flop = %{socket.assigns.metas.flop | page: socket.assigns.metas.next_page}
    metas = %{socket.assigns.metas | flop: flop}

    path = build_paginated_path(metas, socket.assigns.location_params)
    {:noreply, push_patch(socket, to: path)}
  end

  def handle_event("prev", _params, socket) do
    flop = %{socket.assigns.metas.flop | page: socket.assigns.metas.previous_page}
    metas = %{socket.assigns.metas | flop: flop}

    path = build_paginated_path(metas, socket.assigns.location_params)
    {:noreply, push_patch(socket, to: path)}
  end

  # Private helpers

  defp build_profile_query(profile, %{"lat" => lat, "lng" => lng} = _params)
       when is_binary(lat) and is_binary(lng) and lat != "" and lng != "" do
    Profiles.get_other_profiles_distance(profile, lat, lng)
  end

  defp build_profile_query(profile, _params) do
    Profiles.get_other_profiles_distance(profile)
  end

  defp build_location_params(%{"lat" => lat, "lng" => lng})
       when is_binary(lat) and is_binary(lng) and lat != "" and lng != "" do
    "?lat=#{lat}&lng=#{lng}"
  end

  defp build_location_params(_), do: ""

  defp build_paginated_path(metas, location_params) do
    Flop.Phoenix.build_path(~p"/profiles/results" <> location_params, metas)
  end
end
