defmodule Lgb.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto.Query, warn: false
  alias Lgb.Profiles.Starred
  alias Lgb.Repo

  alias Lgb.Profiles.Profile
  alias Lgb.Profiles.ProfilePicture

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles(params) do
    case Flop.validate_and_run(Profile, params, for: Profile) do
      {:ok, {entries, _meta}} -> {:ok, %{entries: entries}}
      error -> error
    end
  end

  def list_starred_profile(profile) do
    query =
      from p in Profile,
        join: starred in Starred,
        on: starred.starred_profile_id == p.id,
        # This is correct - finds stars by this profile
        where: starred.profile_id == ^profile.id,
        select_merge: %{
          distance:
            selected_as(
              fragment(
                "ST_DistanceSphere(?, ?)",
                p.geolocation,
                ^profile.geolocation
              ),
              :distance
            )
        },
        order_by: [asc: selected_as(:distance)],
        preload: [:profile_pictures, :user]

    Repo.all(query)
  end

  def create_starred_profile(attr) do
    Starred.changeset(%Starred{}, attr)
    |> Repo.insert()
  end

  def profile_starred?(profile_id, starred_profile_id) do
    Repo.exists?(
      from s in Starred,
        where: s.profile_id == ^profile_id and s.starred_profile_id == ^starred_profile_id
    )
  end

  def toggle_star(profile_id, starred_profile_id) do
    case profile_starred?(profile_id, starred_profile_id) do
      true ->
        # Delete the star
        Repo.delete_all(
          from s in Starred,
            where: s.profile_id == ^profile_id and s.starred_profile_id == ^starred_profile_id
        )

        {:ok, nil}

      false ->
        # Create the star
        create_starred_profile(%{
          profile_id: profile_id,
          starred_profile_id: starred_profile_id
        })
    end
  end

  @doc """
  Gets a single profile.

  Raises `Ecto.NoResultsError` if the Profile does not exist.

  ## Examples

      iex> get_profile!(123)
      %Profile{}

      iex> get_profile!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile!(id) when is_integer(id), do: Repo.get!(Profile, id)

  def get_profile!(id) when is_binary(id) do
    # If it's a UUID string
    case Ecto.UUID.cast(id) do
      {:ok, uuid} ->
        query =
          from p in Profile,
            where: p.uuid == ^uuid

        Repo.one(query)

      :error ->
        nil
    end
  end

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(user, attrs \\ %{}) do
    Ecto.build_assoc(user, :profiles)
    |> Profile.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profile.

  ## Examples

      iex> update_profile(profile, %{field: new_value})
      {:ok, %Profile{}}

      iex> update_profile(profile, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile(%Profile{} = profile, attrs) do
    profile
    |> Profile.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a profile.

  ## Examples

      iex> delete_profile(profile)
      {:ok, %Profile{}}

      iex> delete_profile(profile)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile(%Profile{} = profile) do
    Repo.delete(profile)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile changes.

  ## Examples

      iex> change_profile(profile)
      %Ecto.Changeset{data: %Profile{}}

  """
  def change_profile(%Profile{} = profile, attrs \\ %{}) do
    Profile.changeset(profile, attrs)
  end

  @doc """
  Create a profile picture.

  First saves the file to the local filesystem, then creates and upload to S3 while recording it to the DB.
  Remove the locally temporary file after the upload.
  """
  def create_profile_picture!(entry, temp_path, profile_id) do
    dest =
      Path.join(
        Application.app_dir(:lgb, "priv/static/uploads"),
        entry.client_name
      )

    File.cp!(temp_path, dest)

    image_upload = %Plug.Upload{
      path: dest,
      filename: entry.client_name,
      content_type: entry.client_type
    }

    %ProfilePicture{}
    |> ProfilePicture.changeset(%{
      profile_id: profile_id,
      image: image_upload
    })
    |> Repo.insert!()

    # Remove the temporary file saved locally
    File.rm!(dest)
  end

  @doc """
  List profile pictures.
  """
  def list_profile_pictures(profile) do
    profile = Repo.preload(profile, :profile_pictures)
    profile.profile_pictures
  end

  def profile_picture_url(profile) do
    profile = Repo.preload(profile, :profile_pictures)

    uploaded_file = Enum.at(profile.profile_pictures, 0)

    if uploaded_file do
      Lgb.Profiles.ProfilePictureUploader.url(
        {uploaded_file.image, uploaded_file},
        :original,
        signed: true
      )
    else
      nil
    end
  end

  def generate_height_options do
    Enum.map(50..85, fn inches ->
      cm = round(inches * 2.54)
      feet = div(inches, 12)
      remaining_inches = rem(inches, 12)
      {"#{feet} ft #{remaining_inches} in", cm}
    end)
  end

  def generate_weight_options do
    Enum.map(100..300, fn lbs ->
      {"#{lbs} lbs", lbs}
    end)
  end

  def get_other_profiles_distance(profile, lat \\ "", lng \\ "") do
    location_point =
      if lat != "" and lng != "" do
        %Geo.Point{coordinates: {String.to_float(lat), String.to_float(lng)}, srid: 4326}
      else
        profile.geolocation
      end

    query =
      from(p in Profile,
        preload: [:profile_pictures, :user],
        select_merge: %{
          distance:
            selected_as(
              fragment(
                "ST_DistanceSphere(?, ?)",
                p.geolocation,
                ^location_point
              ),
              :distance
            )
        }
      )

    query
  end

  def create_filter(params) do
    params
    |> sanitize()
    |> Enum.reduce([], fn {key, value}, acc ->
      case key do
        "min_height_cm" ->
          [%{field: :height_cm, op: :>=, value: String.to_integer(value)} | acc]

        "max_height_cm" ->
          [%{field: :height_cm, op: :<=, value: String.to_integer(value)} | acc]

        "min_age" ->
          [%{field: :age, op: :>=, value: String.to_integer(value)} | acc]

        "max_age" ->
          [%{field: :age, op: :<=, value: String.to_integer(value)} | acc]

        "min_weight" ->
          [%{field: :weight_lb, op: :>=, value: String.to_integer(value)} | acc]

        "max_weight" ->
          [%{field: :weight_lb, op: :<=, value: String.to_integer(value)} | acc]

        "gender" ->
          [%{field: :gender, op: :==, value: value} | acc]

        _ ->
          acc
      end
    end)
  end

  def sanitize(params) do
    params
    |> Enum.reject(fn {_, value} -> value in [nil, ""] end)
  end

  def find_global_users(limit, profile) do
    query =
      from p in Profile,
        # # Ensure they have a picture
        # where: not is_nil(p.first_picture),
        # # Only active profiles
        # where: p.active == true,
        # Random ordering
        select_merge: %{
          distance:
            selected_as(
              fragment(
                "ST_DistanceSphere(?, ?)",
                p.geolocation,
                ^profile.geolocation
              ),
              :distance
            )
        },
        order_by: fragment("RANDOM()"),
        # Adjust number as needed
        limit: ^limit,
        preload: [:profile_pictures, :user]

    query |> Repo.all()
  end

  def find_new_and_nearby_users(limit, profile) do
    # Then when calling the query, you might want to wrap it:
    if profile do
      query =
        from p in Profile,
          where: p.id != ^profile.id,
          where: not is_nil(p.geolocation),
          select_merge: %{
            distance:
              selected_as(
                fragment(
                  "ST_DistanceSphere(?, ?)",
                  p.geolocation,
                  ^profile.geolocation
                ),
                :distance
              )
          },
          order_by: [asc: selected_as(:distance)],
          limit: ^limit,
          preload: [:profile_pictures, :user]

      Repo.all(query)
    else
      []
    end
  end

  def display_weight(lbs) do
    if lbs == nil do
      "⋆.˚"
    else
      "#{lbs} lbs"
    end
  end

  def display_height(cm) do
    if cm == nil do
      "⋆.˚"
    else
      inches = round(cm / 2.54)
      feet = div(inches, 12)
      remaining_inches = rem(inches, 12)
      "#{feet} ft #{remaining_inches} in"
    end
  end

  def display_distance(distance) do
    if distance == nil do
      "⋆.˚"
    else
      miles = distance / 1609.34
      Float.round(miles, 2)
    end
  end

  def calculate_distance(profile, profile_two) do
    query =
      from p in Lgb.Profiles.Profile,
        where: p.id == ^profile.id,
        select:
          fragment(
            # Convert meters to miles
            "ST_DistanceSphere(?, ?)",
            p.geolocation,
            ^profile_two.geolocation
          )

    Lgb.Repo.one(query)
  end

  def current_user(profile) do
    profile
    |> Ecto.assoc(:user)
    |> Lgb.Repo.one()
  end
end
