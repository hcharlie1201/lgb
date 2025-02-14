defmodule Lgb.Food.Recipe do
  use Ecto.Schema
  import Ecto.Changeset

  schema "food_recipes" do
    field :name, :string
    field :ingredients, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(recipe, attrs) do
    recipe
    |> cast(attrs, [:name, :ingredients])
    |> validate_required([:name, :ingredients])
  end
end
