defmodule LgbWeb.ProfileLive.Results do
  alias Lgb.Profiles.Profile
  use LgbWeb, :live_view

  def mount(params, _session, socket) do
    {_, socket} = handle_params(params, nil, socket)
    socket = assign(socket, form: to_form(%{}))
    {:ok, socket}
  end

  @spec handle_params(nil | maybe_improper_list() | map(), any(), any()) :: {:noreply, any()}
  def handle_params(params, _uri, socket) do
    flop_params = %{
      filters: create_filter(params),
      page: params["page"] && String.to_integer(params["page"])
    }

    case Flop.validate_and_run(Profile, flop_params, for: Profile) do
      {:ok, {profiles, metas}} ->
        IO.inspect(metas)
        {:noreply, assign(socket, %{profiles: profiles, metas: metas})}

      {:error, _} ->
        {:noreply, assign(socket, %{profiles: [], metas: nil})}
    end
  end

  @spec handle_event(<<_::32>>, map(), Phoenix.LiveView.Socket.t()) ::
          {:noreply, Phoenix.LiveView.Socket.t()}
  def handle_event("goto", %{"page" => page}, socket) do
    flop = %{socket.assigns.metas.flop | page: page}
    path = Flop.Phoenix.build_path(~p"/profiles/results", flop)

    {:noreply, push_patch(socket, to: path)}
  end

  defp create_filter(params) do
    params
    |> sanitize()
    |> Enum.reduce([], fn {key, value}, acc ->
      case key do
        "min_height_cm" ->
          [%{field: :height_cm, op: :>=, value: String.to_integer(value)} | acc]

        "max_height_cm" ->
          [%{field: :height_cm, op: :<=, value: String.to_integer(value)} | acc]

        _ ->
          acc
      end
    end)
  end

  defp sanitize(params) do
    params
    |> Enum.reject(fn {_, value} -> value in [nil, ""] end)
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
