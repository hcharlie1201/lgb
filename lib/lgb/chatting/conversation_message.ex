defmodule Lgb.Chatting.ConversationMessage do
  use Ecto.Schema
  use Waffle.Ecto.Schema
  import Ecto.Changeset

  schema "conversation_messages" do
    belongs_to :profile, Lgb.Profiles.Profile
    belongs_to :conversation, Lgb.Chatting.Conversation
    field :read, :boolean, default: false
    field :content, :string
    field :image, Lgb.Chatting.ConversationMessageUploader.Type
    field :uuid, Ecto.UUID

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation_message, attrs) do
    conversation_message
    |> cast(attrs, [:content, :read, :profile_id, :conversation_id, :uuid])
    |> unique_constraint(:uuid)
    |> cast_attachments(attrs, [:image])
    |> validate_required([:profile_id, :conversation_id])
    |> validate_content_or_image()
  end

  def typing_changeset(conversation_message, attrs) do
    conversation_message
    |> cast(attrs, [:content])
    |> cast_attachments(attrs, [:image])
  end

  defp validate_content_or_image(changeset) do
    content = get_field(changeset, :content)
    image = get_field(changeset, :image)

    if is_nil(content) and is_nil(image) do
      add_error(changeset, :base, "Either content or image must be present")
    else
      changeset
    end
  end
end
