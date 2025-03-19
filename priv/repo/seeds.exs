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
  limit: 100,
  title: "General"
})

Lgb.Repo.insert!(%Lgb.Accounts.User{
  email: "bob@gmail.com",
  password: "bob@gmail.com",
  hashed_password: Bcrypt.hash_pwd_salt("bob@gmail.com"),
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
  hashed_password: Bcrypt.hash_pwd_salt("james@gmail.com"),
  profiles: [
    %Lgb.Profiles.Profile{
      handle: "Lebron James",
      age: 49,
      biography: "Loves basketball and coding."
    }
  ]
})

# Create more fake profiles
fake_users = [
  %{
    email: "sarah@example.com",
    handle: "Sarah Smith",
    age: 28,
    biography: "Tech enthusiast and yoga instructor. Love trying new restaurants.",
    height_cm: 165,
    weight_lb: 130,
    city: "San Francisco",
    state: "CA",
    zip: "94105"
  },
  %{
    email: "mike@example.com",
    handle: "Mike Johnson",
    age: 35,
    biography: "Professional photographer. Adventure seeker. Coffee addict.",
    height_cm: 183,
    weight_lb: 180,
    city: "Seattle",
    state: "WA",
    zip: "98101"
  },
  %{
    email: "emma@example.com",
    handle: "Emma Wilson",
    age: 31,
    biography: "Book lover and amateur chef. Always planning my next trip.",
    height_cm: 170,
    weight_lb: 140,
    city: "Portland",
    state: "OR",
    zip: "97201"
  },
  %{
    email: "alex@example.com",
    handle: "Alex Chen",
    age: 29,
    biography: "Software engineer by day, musician by night. Rock climbing enthusiast.",
    height_cm: 175,
    weight_lb: 160,
    city: "Austin",
    state: "TX",
    zip: "78701"
  },
  %{
    email: "maya@example.com",
    handle: "Maya Patel",
    age: 27,
    biography: "Digital artist and tea connoisseur. Love exploring art galleries.",
    height_cm: 162,
    weight_lb: 125,
    city: "Chicago",
    state: "IL",
    zip: "60601"
  }
]

# Insert all fake users
Enum.each(fake_users, fn user_data ->
  Lgb.Repo.insert!(%Lgb.Accounts.User{
    email: user_data.email,
    password: "password123456",
    hashed_password: Bcrypt.hash_pwd_salt("password123456"),
    profiles: [
      %Lgb.Profiles.Profile{
        handle: user_data.handle,
        age: user_data.age,
        biography: user_data.biography,
        height_cm: user_data.height_cm,
        weight_lb: user_data.weight_lb,
        city: user_data.city,
        state: user_data.state,
        zip: user_data.zip
      }
    ]
  })
end)

Lgb.Repo.insert!(%Lgb.Subscriptions.SubscriptionPlan{
  stripe_price_id: "price_1Qj7cnJAAjsUxHv9mH5qXwfV"
})

goals = [
  %{name: "Life Partner", description: "Seeking a long-term committed relationship"},
  %{name: "Casual", description: "Open to casual dating"},
  %{
    name: "Intimacy without Commitment",
    description: "Seeking emotional and physical connection without long-term commitment"
  },
  %{name: "Marriage", description: "Looking for a partner to marry"},
  %{
    name: "Ethical Monogamy",
    description: "Committed to honest, consensual monogamous relationship"
  },
  %{name: "Open to Marriage", description: "Potentially interested in marriage"}
]

Enum.each(goals, fn goal ->
  Lgb.Repo.insert!(%Lgb.Profiles.DatingGoal{
    name: goal.name,
    description: goal.description
  })
end)

hobbies = [
  %{name: "Painting"},
  %{name: "Drawing"},
  %{name: "Photography"},
  %{name: "Writing"},
  %{name: "Playing a musical instrument"},
  %{name: "Singing"},
  %{name: "Acting/Theater"},
  %{name: "Dancing"},
  %{name: "Pottery/Ceramics"},
  %{name: "Graphic design"},
  %{name: "Running"},
  %{name: "Weightlifting"},
  %{name: "Yoga"},
  %{name: "Pilates"},
  %{name: "Swimming"},
  %{name: "Cycling"},
  %{name: "Rock climbing"},
  %{name: "Martial arts"},
  %{name: "Hiking"},
  %{name: "Surfing"},
  %{name: "Camping"},
  %{name: "Fishing"},
  %{name: "Kayaking"},
  %{name: "Scuba diving"},
  %{name: "Birdwatching"},
  %{name: "Video games"},
  %{name: "Board games"},
  %{name: "Chess"},
  %{name: "Dungeons & Dragons (D&D)"},
  %{name: "Robotics"},
  %{name: "Astronomy"},
  %{name: "Cooking"},
  %{name: "Baking"},
  %{name: "Wine tasting"},
  %{name: "Mixology (cocktail making)"},
  %{name: "Coffee brewing"},
  %{name: "Watching movies"},
  %{name: "Watching TV shows"},
  %{name: "Anime"},
  %{name: "K-Pop"},
  %{name: "Attending concerts"},
  %{name: "Meditation"},
  %{name: "Traveling"},
  %{name: "Journaling"},
  %{name: "Fashion & styling"},
  %{name: "Gardening"},
  %{name: "Archery"},
  %{name: "Bouldering"},
  %{name: "Skiing"},
  %{name: "Snowboarding"},
  %{name: "Skateboarding"},
  %{name: "Rollerblading"},
  %{name: "Parkour"},
  %{name: "Fencing"},
  %{name: "Tennis"},
  %{name: "Badminton"},
  %{name: "Golf"},
  %{name: "Soccer"},
  %{name: "Basketball"},
  %{name: "Baseball"},
  %{name: "Football"},
  %{name: "Volleyball"},
  %{name: "Table Tennis"},
  %{name: "Bowling"},
  %{name: "Ultimate Frisbee"},
  %{name: "Lacrosse"},
  %{name: "Horseback Riding"},
  %{name: "Sailing"},
  %{name: "Metalworking"},
  %{name: "Woodworking"},
  %{name: "Leathercraft"},
  %{name: "Calligraphy"},
  %{name: "Origami"},
  %{name: "Embroidery"},
  %{name: "Knitting"},
  %{name: "Crocheting"},
  %{name: "Tattoo Art"},
  %{name: "Film Making"},
  %{name: "DJing"},
  %{name: "Beatboxing"},
  %{name: "Rapping"},
  %{name: "Stand-up Comedy"},
  %{name: "Public Speaking"},
  %{name: "Astrology"},
  %{name: "Tarot Reading"},
  %{name: "Foraging"},
  %{name: "Beekeeping"},
  %{name: "Farming"},
  %{name: "Aquascaping"},
  %{name: "Home Brewing"},
  %{name: "Vlogging"},
  %{name: "Podcasting"},
  %{name: "Cosplaying"},
  %{name: "Thrifting"},
  %{name: "Escape Rooms"},
  %{name: "Geocaching"},
  %{name: "Miniature Painting"}
]

Enum.each(hobbies, fn hobby ->
  Lgb.Repo.insert!(%Lgb.Profiles.Hobby{
    name: hobby.name
  })
end)

Enum.each(Lgb.Orientation.SexualOrientation.list_sexual_orientations(), fn sexual_orientation ->
  Lgb.Repo.insert!(%Lgb.Orientation.SexualOrientation{
    category: sexual_orientation
  })
end)
