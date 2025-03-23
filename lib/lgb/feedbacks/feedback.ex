defmodule Lgb.Feedbacks.Feedback do
  use Ecto.Schema
  import Ecto.Changeset
  alias Lgb.Profiles.Profile

  schema "feedbacks" do
    field :title, :string
    field :content, :string
    field :category, :string
    field :rating, :integer
    field :contact_consent, :boolean, default: false

    belongs_to :profile, Profile

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(user_feedback, attrs) do
    user_feedback
    |> cast(attrs, [:title, :content, :category, :rating, :contact_consent, :profile_id])
    |> validate_required([:title, :content, :category, :rating])
    |> validate_inclusion(:rating, 1..5)
  end
end
