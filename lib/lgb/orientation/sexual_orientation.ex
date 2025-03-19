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

  @doc """
  Returns the predefined list of sexual orientation categories.
  
  This list represents the allowed values for the `category` field in the sexual orientation schema.
  """
  @spec list_sexual_orientations() :: [atom()]
  def list_sexual_orientations() do
    @categories
  end

  @doc """
  Generates an Ecto changeset for a sexual orientation record.
  
  Casts the provided attributes map onto the sexual orientation struct and applies validations.
  Note that no fields are currently permitted for casting or required for validation.
  """
  @spec changeset(Lgb.Orientation.SexualOrientation.t(), map) :: Ecto.Changeset.t()
  def changeset(sexual_orientation, attrs) do
    sexual_orientation
    |> cast(attrs, [:category])
    |> validate_required([:category])
    |> validate_inclusion(:category, @categories)
  end
end
