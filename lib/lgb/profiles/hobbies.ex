defmodule Lgb.Profiles.Hobby do
  use Ecto.Schema
  import Ecto.Changeset

  schema "hobbies" do
    field :name, :string

    many_to_many :profiles, Lgb.Profiles.Profile,
      join_through: "profiles_hobbies",
      on_replace: :delete

    timestamps()
  end

  def changeset(goal, attrs) do
    goal
    |> cast(attrs, [:name])
    |> validate_required([:name])
    |> unique_constraint(:name)
  end
end
