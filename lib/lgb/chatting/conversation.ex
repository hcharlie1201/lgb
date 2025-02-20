defmodule Lgb.Chatting.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversations" do
    belongs_to :sender_profile, Lgb.Profiles.Profile
    belongs_to :receiver_profile, Lgb.Profiles.Profile
    has_many :conversation_messages, Lgb.Chatting.ConversationMessage
    field :uuid, Ecto.UUID, read_after_writes: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [:sender_profile_id, :receiver_profile_id])
    |> validate_required([:sender_profile_id, :receiver_profile_id])
    |> validate_profiles_are_different()
    |> foreign_key_constraint(:sender_profile_id)
    |> foreign_key_constraint(:receiver_profile_id)
  end

  defp validate_profiles_are_different(changeset) do
    sender_id = get_field(changeset, :sender_profile_id)
    receiver_id = get_field(changeset, :receiver_profile_id)

    if sender_id == receiver_id do
      add_error(changeset, :receiver_profile_id, "Sender and receiver profiles must be different")
    else
      changeset
    end
  end
end
