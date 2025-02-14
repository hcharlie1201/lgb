defmodule Lgb.Repo.Migrations.CreateFoodRecipes do
  use Ecto.Migration

  def change do
    create table(:food_recipes) do
      add :name, :string
      add :ingredients, :string

      timestamps(type: :utc_datetime)
    end
  end
end
