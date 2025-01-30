defmodule Lgb.Chatting.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    belongs_to :profile, Lgb.Profiles.Profile
    field :chat_room_id, :id
    field :content, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:profile_id, :chat_room_id, :content])
    |> validate_required([:profile_id, :chat_room_id, :content])
  end
end
