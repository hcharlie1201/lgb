defmodule Lgb.Meetups.EventComment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_comments" do
    field :content, :string
    field :likes_count, :integer, default: 0

    belongs_to :event_location, Lgb.Meetups.EventLocation
    belongs_to :profile, Lgb.Profiles.Profile
    has_many :likes, Lgb.Meetups.CommentLike

    has_many :replies, Lgb.Meetups.EventCommentReply, foreign_key: :event_comment_id

    timestamps()
  end

  def changeset(comment, attrs) do
    comment
    |> cast(attrs, [:content, :event_location_id, :profile_id, :likes_count])
    |> validate_required([:content, :event_location_id, :profile_id])
    |> validate_length(:content, min: 1, max: 1000)
  end
end
