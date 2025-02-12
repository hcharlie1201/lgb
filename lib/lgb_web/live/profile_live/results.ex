defmodule LgbWeb.ProfileLive.Results do
  alias Lgb.Profiles.Profile
  alias Lgb.Profiles
  use LgbWeb, :live_view

  def mount(_params, _session, socket) do
    socket = assign(socket, form: to_form(%{}))
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    profile = Lgb.Accounts.User.current_profile(socket.assigns.current_user)
    query = Profiles.get_other_profiles_distance(profile, params["lat"], params["lng"])

    case Flop.validate_and_run(query, params, for: Profile) do
      {:ok, {profiles, metas}} ->
        if params["lat"] != "" and params["lng"] != "" do
          {:noreply,
           assign(socket, %{
             profiles: profiles,
             metas: metas,
             extended_url: "?lat=#{params["lat"]}&lng=#{params["lng"]}"
           })}
        else
          {:noreply, assign(socket, %{profiles: profiles, metas: metas, extended_url: ""})}
        end

      {:error, _} ->
        {:noreply, assign(socket, %{profiles: [], metas: nil})}
    end
  end

  def handle_event("goto", %{"page" => page}, socket) do
    flop = %{socket.assigns.metas.flop | page: page}
    metas = %{socket.assigns.metas | flop: flop}
    path = Flop.Phoenix.build_path(~p"/profiles/results" <> socket.assigns.extended_url, metas)

    {:noreply, push_patch(socket, to: path)}
  end
end
