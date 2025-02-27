defmodule Lgb.Meetups.CommentLike do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comment_likes" do
    belongs_to :event_comment, Lgb.Meetups.EventComment
    belongs_to :profile, Lgb.Profiles.Profile

    timestamps()
  end

  def changeset(like, attrs) do
    like
    |> cast(attrs, [:event_comment_id, :profile_id])
    |> validate_required([:event_comment_id, :profile_id])
    |> unique_constraint([:event_comment_id, :profile_id],
      name: :unique_comment_like,
      message: "You have already liked this comment"
    )
  end
end
