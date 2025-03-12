defmodule Lgb.Orientation do
  @moduledoc """
  The Orientation context.
  """

  import Ecto.Query, warn: false
  alias Lgb.Repo

  alias Lgb.Orientation.SexualOrientation

  @doc """
  Returns the list of sexual_orientations.

  ## Examples

      iex> list_sexual_orientations()
      [%SexualOrientation{}, ...]

  """
  def list_sexual_orientations do
    Repo.all(SexualOrientation)
  end

  @doc """
  Gets a single sexual_orientation.

  Raises `Ecto.NoResultsError` if the Sexual orientation does not exist.

  ## Examples

      iex> get_sexual_orientation!(123)
      %SexualOrientation{}

      iex> get_sexual_orientation!(456)
      ** (Ecto.NoResultsError)

  """
  def get_sexual_orientation!(id), do: Repo.get!(SexualOrientation, id)

  @doc """
  Creates a sexual_orientation.

  ## Examples

      iex> create_sexual_orientation(%{field: value})
      {:ok, %SexualOrientation{}}

      iex> create_sexual_orientation(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_sexual_orientation(attrs \\ %{}) do
    %SexualOrientation{}
    |> SexualOrientation.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a sexual_orientation.

  ## Examples

      iex> update_sexual_orientation(sexual_orientation, %{field: new_value})
      {:ok, %SexualOrientation{}}

      iex> update_sexual_orientation(sexual_orientation, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_sexual_orientation(%SexualOrientation{} = sexual_orientation, attrs) do
    sexual_orientation
    |> SexualOrientation.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a sexual_orientation.

  ## Examples

      iex> delete_sexual_orientation(sexual_orientation)
      {:ok, %SexualOrientation{}}

      iex> delete_sexual_orientation(sexual_orientation)
      {:error, %Ecto.Changeset{}}

  """
  def delete_sexual_orientation(%SexualOrientation{} = sexual_orientation) do
    Repo.delete(sexual_orientation)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking sexual_orientation changes.

  ## Examples

      iex> change_sexual_orientation(sexual_orientation)
      %Ecto.Changeset{data: %SexualOrientation{}}

  """
  def change_sexual_orientation(%SexualOrientation{} = sexual_orientation, attrs \\ %{}) do
    SexualOrientation.changeset(sexual_orientation, attrs)
  end
end
