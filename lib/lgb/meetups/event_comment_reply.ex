defmodule Lgb.Meetups.EventCommentReply do
  use Ecto.Schema
  import Ecto.Changeset

  schema "event_comment_replies" do
    field :content, :string
    field :likes_count, :integer, default: 0

    belongs_to :event_comment, Lgb.Meetups.EventComment
    belongs_to :profile, Lgb.Profiles.Profile

    has_many :likes, Lgb.Meetups.CommentReplyLike
    has_many :liking_profiles, through: [:likes, :profile]

    timestamps()
  end

  def changeset(reply, attrs) do
    reply
    |> cast(attrs, [
      :content,
      :event_comment_id,
      :profile_id,
      :likes_count
    ])
    |> validate_required([:content, :event_comment_id, :profile_id])
    |> validate_length(:content, min: 1, max: 1000)
    |> foreign_key_constraint(:event_comment_id)
    |> foreign_key_constraint(:profile_id)
  end
end
