defmodule Lgb.Meetups.EventLocation do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  @categories [
    :outdoors_activities,
    :sport,
    :technology,
    :hobbies_and_passion,
    :support_and_coaching,
    :art_and_culture,
    :games,
    :dancing,
    :music,
    :reading,
    :animals_and_pets
  ]

  schema "event_locations" do
    field :title, :string
    field :description, :string
    field :date, :utc_datetime
    field :location_name, :string
    field :geolocation, Geo.PostGIS.Geometry
    field :max_participants, :integer, default: 10
    field :category, Ecto.Enum, values: @categories
    field :image, Lgb.Meetups.EventLocationPictureUplodaer.Type
    field :uuid, Ecto.UUID

    belongs_to :creator, Lgb.Profiles.Profile
    many_to_many :participants, Lgb.Profiles.Profile, join_through: "event_participants"
    has_many :event_participants, Lgb.Meetups.EventParticipant

    timestamps()
  end

  def changeset(meetup, attrs) do
    meetup
    |> cast(attrs, [
      :title,
      :description,
      :date,
      :location_name,
      :geolocation,
      :max_participants,
      :creator_id,
      :category,
      :uuid
    ])
    |> validate_required([
      :title,
      :description,
      :date,
      :location_name,
      :geolocation,
      :creator_id,
      :category
    ])
    |> unique_constraint(:uuid)
    |> validate_number(:max_participants, greater_than: 10)
    |> foreign_key_constraint(:creator_id)
    |> cast_attachments(attrs, [:image])
  end

  def categories, do: @categories
end
