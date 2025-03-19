defmodule LgbWeb.ProfileLive.MyProfile do
  alias Lgb.Orientation
  alias Lgb.Accounts.User
  alias Lgb.Profiles
  alias Lgb.Profiles.Profile
  require Logger
  use LgbWeb, :live_view

  @impl true
  @doc """
  Initializes the LiveView socket with the current user's profile and related data.

  This function retrieves the current user from the socket and loads all available dating goals and hobbies from the repository. It then fetches the user's profile and preloads associated dating goals, hobbies, and sexual orientations. Selected dating goals, hobbies, and sexual orientation categories are extracted from the profile. Additionally, the socket is configured with a list of uploaded profile pictures, a changeset for form handling, and file upload settings for avatar images (accepting image files with a maximum of three entries).

  Returns `{:ok, socket}` with the updated assigns.
  """
  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    dating_goals = Lgb.Repo.all(Lgb.Profiles.DatingGoal)
    hobbies = Lgb.Repo.all(Lgb.Profiles.Hobby)

    profile =
      User.current_profile(user)
      |> Lgb.Repo.preload([:dating_goals, :hobbies, :sexual_orientations])

    selected_goals = profile.dating_goals
    selected_hobbies = profile.hobbies
    selected_sexual_orientations = Enum.map(profile.sexual_orientations, & &1.category)

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
        selected_sexual_orientations: selected_sexual_orientations,
        sexual_orientations: Lgb.Orientation.SexualOrientation.list_sexual_orientations(),
        search_query: ""
      )
      |> allow_upload(:avatar, accept: ~w(image/*), max_entries: 3)

    {:ok, assign(socket, profile: profile, form: to_form(Profile.changeset(profile, %{})))}
  end

  @doc """
  Handles the profile update event by merging geolocation data, updating the profile, and processing associated resources.

  This function integrates any available geolocation information into the submitted profile parameters before attempting to update the user's profile. If the update is successful, it consumes uploaded avatar entries to create profile picture records and saves related dating goals, hobbies, and sexual orientations. The socket is then updated with the new profile and a success flash message. In case of an error, the function assigns the resulting changeset to the socket and sets an error flash message.
  """
  def handle_event("update_profile", profile_params, socket) do
    profile_params = handle_geo_location(profile_params, socket)

    case Profiles.update_profile(socket.assigns.profile, profile_params) do
      {:ok, profile} ->
        consume_uploaded_entries(socket, :avatar, fn %{path: path}, entry ->
          Profiles.create_profile_picture!(entry, path, profile.id)
        end)

        Profiles.save_dating_goals(profile, socket.assigns.selected_goals)
        Profiles.save_hobbies(profile, socket.assigns.selected_hobbies)
        Orientation.save_sexual_orientations(profile, socket.assigns.selected_sexual_orientations)

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

  @doc """
  Toggles a hobby's selection state in the user's profile.

  If the hobby corresponding to the given id is already selected, it is removed from the list of selected hobbies. Otherwise, the hobby is added to the list. The updated list is then assigned to the socket.
  """
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

  @doc """
  Toggles the selection of a sexual orientation category in the user profile.

  If the category is already selected, it is removed; otherwise, if fewer than two categories are selected, it is added. This ensures that a maximum of two orientations are maintained.
  """
  def handle_event("toggle_sexual_orientation", %{"category" => category}, socket) do
    category = String.to_existing_atom(category)

    updated_sexual_orientations =
      if category in socket.assigns.selected_sexual_orientations do
        Enum.reject(socket.assigns.selected_sexual_orientations, &(&1 == category))
      else
        # Add the category if there's room (limit to 2)
        if length(socket.assigns.selected_sexual_orientations) < 2 do
          [category | socket.assigns.selected_sexual_orientations]
        else
          socket.assigns.selected_sexual_orientations
        end
      end

    {:noreply, assign(socket, :selected_sexual_orientations, updated_sexual_orientations)}
  end

  @doc """
  Deletes a profile picture from the user's profile.

  Retrieves the profile picture using the provided ID from the event payload and attempts
  to delete it from the repository. On successful deletion, refreshes the socket's assigned list
  of uploaded profile pictures; if the deletion fails, returns an error tuple with the unchanged socket.
  """
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
