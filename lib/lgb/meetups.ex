defmodule Lgb.Meetups do
  import Ecto.Query
  alias Lgb.Repo
  alias Lgb.Meetups.Meetup

  def list_meetups do
    Repo.all(from m in Meetup, preload: [:host, :participants])
  end

  def get_meetup!(id) do
    Repo.get!(Meetup, id) |> Repo.preload([:host, :participants])
  end

  def create_meetup(attrs, user) do
    %Meetup{}
    |> Meetup.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:host, user)
    |> Repo.insert()
  end

  def update_meetup(%Meetup{} = meetup, attrs) do
    meetup
    |> Meetup.changeset(attrs)
    |> Repo.update()
  end

  def delete_meetup(%Meetup{} = meetup) do
    Repo.delete(meetup)
  end

  def join_meetup(%Meetup{} = meetup, user) do
    meetup = Repo.preload(meetup, :participants)
    
    meetup
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:participants, [user | meetup.participants])
    |> Repo.update()
  end

  def leave_meetup(%Meetup{} = meetup, user) do
    meetup = Repo.preload(meetup, :participants)
    
    meetup
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(:participants, Enum.reject(meetup.participants, & &1.id == user.id))
    |> Repo.update()
  end
end
