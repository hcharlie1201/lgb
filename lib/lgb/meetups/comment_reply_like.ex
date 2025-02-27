defmodule Lgb.Meetups.CommentReplyLike do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comment_reply_likes" do
    belongs_to :event_comment_reply, Lgb.Meetups.EventCommentReply
    belongs_to :profile, Lgb.Profiles.Profile

    timestamps()
  end

  def changeset(like, attrs) do
    like
    |> cast(attrs, [:event_comment_reply_id, :profile_id])
    |> validate_required([:event_comment_reply_id, :profile_id])
    |> unique_constraint([:event_comment_reply_id, :profile_id],
      name: :unique_comment_reply_like,
      message: "You have already liked this reply"
    )
  end
end
