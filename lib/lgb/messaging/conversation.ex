defmodule Lgb.Messaging.Conversation do
  use Ecto.Schema
  import Ecto.Changeset

  schema "conversations" do

    field :sender_id, :id
    field :receiver_id, :id

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(conversation, attrs) do
    conversation
    |> cast(attrs, [])
    |> validate_required([])
  end
end
