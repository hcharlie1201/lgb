defmodule Lgb.Meetups.Meetup do
  use Ecto.Schema
  import Ecto.Changeset

  @categories [
    "outdoors_activities",
    "sport",
    "technology",
    "hobbies_and_passion",
    "support_and_coaching",
    "art_and_culture",
    "games",
    "dancing",
    "music",
    "reading",
    "animals_and_pets"
  ]

  schema "meetups" do
    field :title, :string
    field :description, :string
    field :date, :utc_datetime
    field :location_name, :string
    field :latitude, :float
    field :longitude, :float
    field :max_participants, :integer, default: 10
    field :category, Ecto.Enum, values: @categories
    
    belongs_to :creator, Lgb.Profiles.Profile
    many_to_many :participants, Lgb.Profiles.Profile, join_through: "meetup_participants"

    timestamps()
  end

  def changeset(meetup, attrs) do
    meetup
    |> cast(attrs, [:title, :description, :date, :location_name, :latitude, :longitude, :max_participants, :creator_id, :category])
    |> validate_required([:title, :description, :date, :location_name, :latitude, :longitude, :creator_id, :category])
    |> validate_number(:max_participants, greater_than: 0)
    |> foreign_key_constraint(:creator_id)
  end
  
  def categories, do: @categories
end
