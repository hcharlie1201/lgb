defmodule Lgb.Profiles.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Flop.Schema,
    filterable: [:handle, :state, :city, :height_cm, :weight_lb, :age],
    sortable: [:age, :height_cm, :weight_lb],
    default_limit: 1
  }

  schema "profiles" do
    has_many :profile_pictures, Lgb.Profiles.ProfilePicture
    belongs_to :user, Lgb.Accounts.User
    field :handle, :string
    field :state, :string
    field :zip, :string
    field :age, :integer
    field :height_cm, :integer
    field :weight_lb, :integer
    field :city, :string
    field :biography, :string
    field :geolocation, Geo.PostGIS.Geometry

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile, attrs \\ %{}) do
    profile
    |> cast(attrs, [
      :handle,
      :age,
      :height_cm,
      :weight_lb,
      :city,
      :state,
      :zip,
      :biography,
      :user_id,
      :geolocation
    ])
    |> validate_required([:user_id])
    |> validate_number(:age,
      greater_than_or_equal_to: 18,
      less_than_or_equal_to: 100,
      message: "Age must be between 18 and 100"
    )

    # TODO: validate height, weight, zip to city is valid
  end
end
