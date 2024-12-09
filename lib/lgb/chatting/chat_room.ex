defmodule Lgb.Chatting.ChatRoom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_rooms" do
    field :limit, :integer
    field :description, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat_room, attrs) do
    chat_room
    |> cast(attrs, [:limit])
    |> cast(attrs, [:description])
    |> validate_required([:description])
    |> validate_required([:limit])
  end
end
