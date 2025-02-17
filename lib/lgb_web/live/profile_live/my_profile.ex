defmodule LgbWeb.ProfileLive.MyProfile do
  alias Lgb.Accounts.User
  alias Lgb.Profiles
  alias Lgb.Profiles.Profile
  alias LgbWeb.Components.Carousel
  require Logger
  use LgbWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user

    profile = User.current_profile(user)

    socket =
      socket
      |> assign(:uploaded_files, Profiles.list_profile_pictures(profile))
      |> allow_upload(:avatar, accept: ~w(image/*), max_entries: 3)

    {:ok, assign(socket, profile: profile, form: to_form(Profile.changeset(profile, %{})))}
  end

  def handle_event("update_profile", profile_params, socket) do
    profile_params = handle_geo_location(profile_params, socket)

    case Profiles.update_profile(socket.assigns.profile, profile_params) do
      {:ok, profile} ->
        consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
          Profiles.create_profile_picture!(entry, path, profile.id)
        end)

        {:noreply,
         socket
         |> assign(:uploaded_files, Profiles.list_profile_pictures(profile))
         |> assign(:profile, profile)
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

  @doc """
  Updates the geolocation and address details in the form.
  """
  def handle_event("map_clicked", %{"lat" => lat, "lng" => lng}, socket) do
    case Lgb.ThirdParty.Google.ReverseGeo.get_address(lat, lng) do
      [city: city, state: state, zip: zip] ->
        updated_params =
          Map.merge(
            %{
              "geolocation" => %Geo.Point{coordinates: {lat, lng}, srid: 4326},
              "city" => city,
              "state" => state,
              "zip" => zip
            },
            socket.assigns.form.params
          )

        form =
          socket.assigns.profile
          |> Profile.changeset(updated_params)
          |> Map.put(:action, :validate)
          |> to_form()

        {:noreply, assign(socket, form: form)}

      _ ->
        {:noreply, put_flash(socket, :error, "Failed to fetch address details.")}
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

  # special case since form doesn't accept struct so we have to update it manually
  defp handle_geo_location(params, socket) do
    case socket.assigns.form.params["geolocation"] do
      nil ->
        params

      geolocation ->
        Map.merge(params, %{
          "geolocation" => geolocation,
          "zip" => socket.assigns.form.params["zip"],
          "city" => socket.assigns.form.params["city"],
          "state" => socket.assigns.form.params["state"]
        })
    end
  end

  @impl true
  def handle_info(:remove_profile_picture, socket) do
    {:noreply,
     assign(socket, :uploaded_files, Profiles.list_profile_pictures(socket.assigns.profile))}
  end

  @impl true
  def handle_info({LgbWeb.Presence, {:join, _presence}}, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_info({LgbWeb.Presence, {:leave, _presence}}, socket) do
    {:noreply, socket}
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
