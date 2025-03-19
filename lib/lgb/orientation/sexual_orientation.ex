defmodule Lgb.Orientation.SexualOrientation do
  use Ecto.Schema
  import Ecto.Changeset

  @categories [
    :bisexual,
    :bisexual_straight_leaning,
    :bisexual_straight_curious,
    :bisexual_gay_curious,
    :bisexual_gay_leaning,
    :straight,
    :asexual,
    :demisexual,
    :sapiosexual,
    :pansexual,
    :graysexual,
    :gay,
    :lesbian
  ]

  schema "sexual_orientations" do
    field :category, Ecto.Enum, values: @categories

    timestamps(type: :utc_datetime)
  end

  def list_sexual_orientations() do
    @categories
  end

  @doc false
  def changeset(sexual_orientation, attrs) do
    sexual_orientation
    |> cast(attrs, [:category])
    |> validate_required([:category])
    |> validate_inclusion(:category, @categories)
  end
end
