defmodule LgbWeb.ProfileLive.MyProfile do
  alias Lgb.Accounts.User
  alias Lgb.Profiles
  alias Lgb.Profiles.Profile
  require Logger
  use LgbWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    dating_goals = Lgb.Repo.all(Lgb.Profiles.DatingGoal)
    hobbies = Lgb.Repo.all(Lgb.Profiles.Hobby)

    profile = User.current_profile(user) |> Lgb.Repo.preload([:dating_goals, :hobbies])
    selected_goals = profile.dating_goals
    selected_hobbies = profile.hobbies

    socket =
      socket
      |> assign(
        current_index: 0,
        length: 3,
        uploaded_files: Profiles.list_profile_pictures(profile),
        dating_goals: dating_goals,
        selected_goals: selected_goals,
        hobbies: hobbies,
        selected_hobbies: selected_hobbies,
        search_query: ""
      )
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

        Profiles.save_dating_goals(profile, socket.assigns.selected_goals)
        Profiles.save_hobbies(profile, socket.assigns.selected_hobbies)

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

  def handle_event("next", _, socket) do
    current_index = rem(socket.assigns.current_index + 1, length(socket.assigns.uploaded_files))
    {:noreply, assign(socket, current_index: current_index)}
  end

  def handle_event("prev", _, socket) do
    current_index =
      rem(
        socket.assigns.current_index - 1 + length(socket.assigns.uploaded_files),
        length(socket.assigns.uploaded_files)
      )

    {:noreply, assign(socket, current_index: current_index)}
  end

  @impl Phoenix.LiveView
  def handle_event("cancel-upload", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :avatar, ref)}
  end

  def handle_event("toggle_goal", %{"id" => id}, socket) do
    goal = Enum.find(socket.assigns.dating_goals, &(to_string(&1.id) == id))

    updated_goals =
      if Enum.any?(socket.assigns.selected_goals, &(&1.id == goal.id)) do
        Enum.reject(socket.assigns.selected_goals, &(&1.id == goal.id))
      else
        if length(socket.assigns.selected_goals) < 2 do
          [goal | socket.assigns.selected_goals]
        else
          socket.assigns.selected_goals
        end
      end

    {:noreply, assign(socket, :selected_goals, updated_goals)}
  end

  def handle_event("toggle_hobby", %{"id" => id}, socket) do
    hobby = Enum.find(socket.assigns.hobbies, &(to_string(&1.id) == id))

    updated_hobbies =
      if Enum.any?(socket.assigns.selected_hobbies, &(&1.id == hobby.id)) do
        Enum.reject(socket.assigns.selected_hobbies, &(&1.id == hobby.id))
      else
        [hobby | socket.assigns.selected_hobbies]
      end

    {:noreply, assign(socket, :selected_hobbies, updated_hobbies)}
  end

  def handle_event("delete_profile_picture", %{"profile-pic-id" => id}, socket) do
    profile_picture = Lgb.Profiles.ProfilePicture.get!(id)

    case Lgb.Repo.delete(profile_picture) do
      {:ok, _} ->
        {:noreply,
         assign(socket, :uploaded_files, Profiles.list_profile_pictures(socket.assigns.profile))}

      {:error, _} ->
        {:error, socket}
    end
  end

  def handle_event("search", %{"value" => query}, socket) do
    hobbies = Profiles.list_hobbies(query)
    {:noreply, assign(socket, :hobbies, hobbies)}
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
