defmodule Lgb.Meetups.Meetup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "meetups" do
    field :title, :string
    field :description, :text
    field :date, :utc_datetime
    field :location_name, :string
    field :latitude, :float
    field :longitude, :float
    field :max_participants, :integer
    
    belongs_to :host, Lgb.Accounts.User
    many_to_many :participants, Lgb.Accounts.User, join_through: "meetup_participants"

    timestamps()
  end

  def changeset(meetup, attrs) do
    meetup
    |> cast(attrs, [:title, :description, :date, :location_name, :latitude, :longitude, :max_participants])
    |> validate_required([:title, :description, :date, :location_name, :latitude, :longitude])
    |> validate_number(:max_participants, greater_than: 0)
  end
end
