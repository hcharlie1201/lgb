defmodule LgbWeb.ProfileLiveTest do
  use LgbWeb.ConnCase

  import Phoenix.LiveViewTest
  import Lgb.AccountsFixtures
  import Lgb.ProfilesFixtures

  @create_attrs %{
    handle: "some handle",
    state: "some state",
    zip: "some zip",
    dob: "2024-12-11",
    height_cm: 42,
    weight_lb: 42,
    city: "some city",
    biography: "some biography"
  }
  @update_attrs %{
    handle: "some updated handle",
    state: "some updated state",
    zip: "some updated zip",
    dob: "2024-12-12",
    height_cm: 43,
    weight_lb: 43,
    city: "some updated city",
    biography: "some updated biography"
  }
  @invalid_attrs %{
    handle: nil,
    state: nil,
    zip: nil,
    dob: nil,
    height_cm: nil,
    weight_lb: nil,
    city: nil,
    biography: nil
  }

  setup do
    user = user_fixture()
    profile = profile_fixture(user)
    conn = log_in_user(build_conn(), user)
    %{user: user, profile: profile, conn: conn}
  end
end
