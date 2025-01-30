defmodule Lgb.Chatting.ChatRoom do
  use Ecto.Schema
  import Ecto.Changeset

  schema "chat_rooms" do
    field :limit, :integer
    field :description, :string
    field :title, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(chat_room, attrs) do
    chat_room
    |> cast(attrs, [:description, :title, :limit])
    |> validate_required([:description, :limit])
  end
end
