# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Lgb.Repo.insert!(%Lgb.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Lgb.Repo.insert!(%Lgb.Chatting.ChatRoom{
  description: "General chat room for everyone",
  limit: 100
})
