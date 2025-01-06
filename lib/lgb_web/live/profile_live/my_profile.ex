defmodule LgbWeb.ProfileLive.MyProfile do
  alias Lgb.Accounts.User
  alias Lgb.Profiles
  alias Lgb.Profiles.Profile
  require Logger
  use LgbWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    profile =
      case User.current_profile(user) do
        nil ->
          {:ok, new_profile} = Profiles.create_profile(%{user_id: user.id})
          new_profile

        existing_profile ->
          existing_profile
      end

    socket =
      socket
      |> assign(:uploaded_files, Profiles.list_profile_pictures(profile))
      |> allow_upload(:avatar, accept: ~w(image/*), max_entries: 3)

    {:ok, assign(socket, profile: profile, form: to_form(Profile.changeset(profile, %{})))}
  end

  @doc """
  Handles events from the client from app.js Hooks.map.
  """
  def handle_event("map_clicked", %{"lat" => lat, "lng" => lng}, socket) do
    updated_form =
      Map.update!(socket.assigns.form, :params, fn params_map ->
        Map.put(params_map, "geolocation", %Geo.Point{coordinates: {lat, lng}, srid: 4326})
      end)

    {:noreply, assign(socket, form: updated_form)}
  end

  def handle_event("update_profile", profile_params, socket) do
    geolocation = socket.assigns.form.params["geolocation"]
    profile_params = Map.put(profile_params, "geolocation", geolocation)

    case Profiles.update_profile(socket.assigns.profile, profile_params) do
      {:ok, profile} ->
        consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
          Profiles.create_profile_picture!(entry, path, profile.id)
        end)

        {:noreply,
         socket
         |> assign(:uploaded_files, Profiles.list_profile_pictures(profile))
         |> put_flash(:info, "Profile updated successfully!")}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:form, to_form(changeset))
         |> put_flash(
           :error,
           "Failed to update profile."
         )}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate", params, socket) do
    profile = socket.assigns.profile

    form =
      profile
      |> Profile.changeset(params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, form: form)}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  @impl Phoenix.LiveView
  def handle_event("validate_zip", %{"zip" => zip}, socket) do
    case zip do
      "" ->
        {:noreply, socket}

      _ ->
        if String.length(zip) > 5 or !String.match?(zip, ~r/^\d+$/) do
          assign(socket, :form, %{socket.assign.form | zip: ""} |> to_form())
          {:noreply, put_flash(socket, :error, "Must be a valid zip")}
        else
          {:noreply, socket}
        end
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
