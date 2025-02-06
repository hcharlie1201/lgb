defmodule Lgb.ProfileViews do
  @moduledoc """
  The ProfileViews context.
  """

  import Ecto.Query, warn: false
  alias Lgb.Repo

  alias Lgb.ProfileViews.ProfileView

  @doc """
  Returns the list of profile_views.

  ## Examples

      iex> list_profile_views()
      [%ProfileView{}, ...]

  """
  def list_profile_views do
    Repo.all(ProfileView)
  end

  @doc """
  Gets a single profile_view.

  Raises `Ecto.NoResultsError` if the Profile view does not exist.

  ## Examples

      iex> get_profile_view!(123)
      %ProfileView{}

      iex> get_profile_view!(456)
      ** (Ecto.NoResultsError)

  """
  def get_profile_view!(id), do: Repo.get!(ProfileView, id)

  @doc """
  Creates a profile_view.

  ## Examples

      iex> create_profile_view(%{field: value})
      {:ok, %ProfileView{}}

      iex> create_profile_view(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_profile_view(attrs \\ %{}) do
    %ProfileView{}
    |> ProfileView.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a profile_view.

  ## Examples

      iex> update_profile_view(profile_view, %{field: new_value})
      {:ok, %ProfileView{}}

      iex> update_profile_view(profile_view, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_profile_view(%ProfileView{} = profile_view, attrs) do
    profile_view
    |> ProfileView.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a profile_view.

  ## Examples

      iex> delete_profile_view(profile_view)
      {:ok, %ProfileView{}}

      iex> delete_profile_view(profile_view)
      {:error, %Ecto.Changeset{}}

  """
  def delete_profile_view(%ProfileView{} = profile_view) do
    Repo.delete(profile_view)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking profile_view changes.

  ## Examples

      iex> change_profile_view(profile_view)
      %Ecto.Changeset{data: %ProfileView{}}

  """
  def change_profile_view(%ProfileView{} = profile_view, attrs \\ %{}) do
    ProfileView.changeset(profile_view, attrs)
  end

  def create_or_update_profile_view(attrs \\ %{}) do
    if attrs[:viewer_id] != attrs[:viewed_profile_id] do
      %ProfileView{}
      |> ProfileView.changeset(attrs)
      |> Repo.insert!(
        on_conflict: [set: [updated_at: DateTime.utc_now()]],
        conflict_target: [:viewer_id, :viewed_profile_id]
      )
    end
  end

  def find_profile_views(profile, limit \\ 10) do
    if profile do
      query =
        from p in ProfileView,
          where: p.viewed_profile_id == ^profile.id,
          order_by: [desc: p.inserted_at],
          limit: ^limit,
          preload: [viewer: [:profile_pictures, :user]]

      Repo.all(query)
    else
      []
    end
  end
end
