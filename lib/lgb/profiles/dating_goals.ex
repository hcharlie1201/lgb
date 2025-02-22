defmodule Lgb.Profiles.DatingGoal do
  use Ecto.Schema
  import Ecto.Changeset

  schema "dating_goals" do
    field :name, :string
    field :description, :string

    many_to_many :profiles, Lgb.Profiles.Profile,
      join_through: "profiles_dating_goals",
      on_replace: :delete

    timestamps()
  end

  def changeset(goal, attrs) do
    goal
    |> cast(attrs, [:name, :description])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
