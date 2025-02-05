defmodule LgbWeb.ChatRoomLive.Index do
  use LgbWeb, :live_view

  alias Lgb.Chatting

  def mount(_params, _session, socket) do
    {:ok, stream(socket, :chat_rooms, Chatting.list_chat_rooms())}
  end
end
