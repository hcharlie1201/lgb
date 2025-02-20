defmodule Lgb.Chatting.ConversationMessage do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversation_messages" do
    belongs_to :profile, Lgb.Profiles.Profile
    belongs_to :conversation, Lgb.Chatting.Conversation
    field :read, :boolean, default: false
    field :content, :string
    field :uuid, Ecto.UUID, read_after_writes: true

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation_message, attrs) do
    conversation_message
    |> cast(attrs, [:content, :read, :profile_id, :conversation_id])
    |> validate_required([:profile_id, :conversation_id])
    |> validate_required([:content])
  end

  def typing_changeset(conversation_message, attrs) do
    conversation_message
    |> cast(attrs, [:content])
  end
end
