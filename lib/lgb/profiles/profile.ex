defmodule Lgb.Profiles.Profile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "profiles" do
    has_many :profile_pictures, Lgb.Profiles.ProfilePicture
    belongs_to :user, Lgb.Accounts.User
    field :handle, :string
    field :state, :string
    field :zip, :string
    field :dob, :date
    field :height_cm, :integer
    field :weight_lb, :integer
    field :city, :string
    field :biography, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(profile, attrs \\ %{}) do
    profile
    |> cast(attrs, [
      :handle,
      :dob,
      :height_cm,
      :weight_lb,
      :city,
      :state,
      :zip,
      :biography,
      :user_id
    ])
    |> validate_required([:user_id])
  end
end
