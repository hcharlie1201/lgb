defmodule LgbWeb.ProfileLive.Results do
  alias Lgb.Profiles.Profile
  use LgbWeb, :live_view

  def mount(params, _session, socket) do
    {_, socket} = handle_params(params, nil, socket)
    socket = assign(socket, form: to_form(%{}))
    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    case Flop.validate_and_run(Profile, params, for: Profile) do
      {:ok, {profiles, metas}} ->
        IO.inspect(metas)
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

  defp display_weight(lbs) do
    if lbs == nil do
      "n/a"
    else
      "#{lbs} lbs"
    end
  end

  def display_height(cm) do
    if cm == nil do
      "n/a"
    else
      inches = round(cm / 2.54)
      feet = div(inches, 12)
      remaining_inches = rem(inches, 12)
      "#{feet} ft #{remaining_inches} in"
    end
  end
end
