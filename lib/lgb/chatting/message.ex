defmodule Lgb.Chatting.Message do
  use Ecto.Schema
  import Ecto.Changeset

  schema "messages" do
    field :user_id, :id
    field :chat_room_id, :id
    field :content, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(message, attrs) do
    message
    |> cast(attrs, [:user_id, :chat_room_id, :content])
    |> validate_required([:user_id, :chat_room_id, :content])
  end
end
