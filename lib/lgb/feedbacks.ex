defmodule Lgb.Feedbacks do
  @moduledoc """
  The Feedback context.
  """

  import Ecto.Query, warn: false
  alias Lgb.Repo
  alias Lgb.Feedbacks.Feedback

  @doc """
  Returns the list of user_feedbacks.

  ## Examples

      iex> list_user_feedbacks()
      [%UserFeedback{}, ...]

  """
  def list_user_feedbacks do
    Repo.all(Feedback)
  end

  @doc """
  Gets a single user_feedback.

  Raises `Ecto.NoResultsError` if the User feedback does not exist.

  ## Examples

      iex> get_user_feedback!(123)
      %UserFeedback{}

      iex> get_user_feedback!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user_feedback!(id), do: Repo.get!(Feedback, id)

  @doc """
  Creates a user_feedback.

  ## Examples

      iex> create_user_feedback(%{field: value})
      {:ok, %UserFeedback{}}

      iex> create_user_feedback(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user_feedback(attrs \\ %{}) do
    %Feedback{}
    |> Feedback.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user_feedback.

  ## Examples

      iex> update_user_feedback(user_feedback, %{field: new_value})
      {:ok, %UserFeedback{}}

      iex> update_user_feedback(user_feedback, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user_feedback(%Feedback{} = feedback, attrs) do
    feedback
    |> Feedback.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a user_feedback.

  ## Examples

      iex> delete_user_feedback(feedback)
      {:ok, %UserFeedback{}}

      iex> delete_user_feedback(feedback)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user_feedback(%Feedback{} = feedback) do
    Repo.delete(feedback)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user_feedback changes.

  ## Examples

      iex> change_user_feedback(user_feedback)
      %Ecto.Changeset{data: %UserFeedback{}}

  """
  def change_user_feedback(%Feedback{} = feedback, attrs \\ %{}) do
    Feedback.changeset(feedback, attrs)
  end

  @doc """
  Returns feedbacks grouped by category with their average ratings.
  """
  def feedback_stats() do
    query =
      from f in Feedback,
        group_by: f.category,
        select: %{
          category: f.category,
          count: count(f.id),
          avg_rating: avg(f.rating)
        }

    Repo.all(query)
  end

  @doc """
  Returns the latest feedbacks.
  """
  def recent_feedbacks(limit \\ 10) do
    query =
      from f in Feedback,
        order_by: [desc: f.inserted_at],
        limit: ^limit

    Repo.all(query)
  end
end
