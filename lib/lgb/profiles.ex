defmodule Lgb.Profiles do
  @moduledoc """
  The Profiles context.
  """

  import Ecto.Query, warn: false
  alias Lgb.Repo

  alias Lgb.Profiles.Profile
  alias Lgb.Profiles.ProfilePicture

  @doc """
  Returns the list of profiles.

  ## Examples

      iex> list_profiles()
      [%Profile{}, ...]

  """
  def list_profiles do
    Repo.all(Profile)
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
  def get_profile!(id), do: Repo.get!(Profile, id)

  @doc """
  Creates a profile.

  ## Examples

      iex> create_profile(%{field: value})
      {:ok, %Profile{}}

      iex> create_profile(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile(attrs \\ %{}) do
    %Profile{}
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
    profile
    |> Ecto.assoc(:profile_pictures)
    |> Repo.all()
  end
end
