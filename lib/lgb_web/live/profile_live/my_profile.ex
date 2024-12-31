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

  def handle_event("update_profile", profile_params, socket) do
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
         |> put_flash(:error, "Failed to update profile.")}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
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

  defp generate_height_options do
    Enum.map(50..85, fn inches ->
      cm = round(inches * 2.54)
      feet = div(inches, 12)
      remaining_inches = rem(inches, 12)
      {"#{feet} ft #{remaining_inches} in", cm}
    end)
  end

  defp generate_weight_options do
    Enum.map(100..300, fn lbs ->
      {"#{lbs} lbs", lbs}
    end)
  end

  defp generate_state_options do
    [
      {"Alabama", "AL"},
      {"Alaska", "AK"},
      {"Arizona", "AZ"},
      {"Arkansas", "AR"},
      {"California", "CA"},
      {"Colorado", "CO"},
      {"Connecticut", "CT"},
      {"Delaware", "DE"},
      {"Florida", "FL"},
      {"Georgia", "GA"},
      {"Hawaii", "HI"},
      {"Idaho", "ID"},
      {"Illinois", "IL"},
      {"Indiana", "IN"},
      {"Iowa", "IA"},
      {"Kansas", "KS"},
      {"Kentucky", "KY"},
      {"Louisiana", "LA"},
      {"Maine", "ME"},
      {"Maryland", "MD"},
      {"Massachusetts", "MA"},
      {"Michigan", "MI"},
      {"Minnesota", "MN"},
      {"Mississippi", "MS"},
      {"Missouri", "MO"},
      {"Montana", "MT"},
      {"Nebraska", "NE"},
      {"Nevada", "NV"},
      {"New Hampshire", "NH"},
      {"New Jersey", "NJ"},
      {"New Mexico", "NM"},
      {"New York", "NY"},
      {"North Carolina", "NC"},
      {"North Dakota", "ND"},
      {"Ohio", "OH"},
      {"Oklahoma", "OK"},
      {"Oregon", "OR"},
      {"Pennsylvania", "PA"},
      {"Rhode Island", "RI"},
      {"South Carolina", "SC"},
      {"South Dakota", "SD"},
      {"Tennessee", "TN"},
      {"Texas", "TX"},
      {"Utah", "UT"},
      {"Vermont", "VT"},
      {"Virginia", "VA"},
      {"Washington", "WA"},
      {"West Virginia", "WV"},
      {"Wisconsin", "WI"},
      {"Wyoming", "WY"}
    ]
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
end
