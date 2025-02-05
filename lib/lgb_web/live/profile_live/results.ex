defmodule LgbWeb.ProfileLive.Results do
  alias Lgb.Profiles.Profile
  alias LgbWeb.Components.Carousel
  alias Lgb.Profiles
  use LgbWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, form: to_form(%{}))
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
    query = Profiles.get_other_profiles_distance(profile)

    case Flop.validate_and_run(query, params, for: Profile) do
      {:ok, {profiles, metas}} ->
        {:noreply, assign(socket, %{profiles: profiles, metas: metas})}

      {:error, _} ->
        {:noreply, assign(socket, %{profiles: [], metas: nil})}
    end
  end

  def handle_event("goto", %{"page" => page}, socket) do
    flop = %{socket.assigns.metas.flop | page: page}
    metas = %{socket.assigns.metas | flop: flop}
    path = Flop.Phoenix.build_path(~p"/profiles/results", metas)

    {:noreply, push_patch(socket, to: path)}
  end
end
