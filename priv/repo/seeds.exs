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

Lgb.Repo.insert!(%Lgb.Accounts.User{
  email: "bob@gmail.com",
  password: "bob@gmail.com",
  hashed_password: "bob@gmail.com",
  profiles: [
    %Lgb.Profiles.Profile{
      handle: "John Doe",
      age: 30,
      biography: "Loves programming and hiking."
    }
  ]
})

Lgb.Repo.insert!(%Lgb.Accounts.User{
  email: "james@gmail.com",
  password: "james@gmail.com",
  hashed_password: "james@gmail.com",
  profiles: [
    %Lgb.Profiles.Profile{
      handle: "Lebron James",
      age: 49,
      biography: "Loves basketball and coding."
    }
  ]
})
