defmodule LgbWeb.Router do
  use LgbWeb, :router

  import LgbWeb.UserAuth

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {LgbWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :fetch_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", LgbWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    get "/", PageController, :home
    post "/waitlist", WaitlistController, :create
  end

  # Other scopes may use custom stacks.
  # scope "/api", LgbWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:lgb, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: LgbWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  ## Authentication routes

  scope "/", LgbWeb do
    pipe_through [:browser, :redirect_if_user_is_authenticated]

    live_session :redirect_if_user_is_authenticated,
      on_mount: [{LgbWeb.UserAuth, :redirect_if_user_is_authenticated}] do
      live "/users/register", LoginLive.UserRegistrationLive, :new
      live "/users/log_in", LoginLive.UserLoginLive, :new
      live "/users/reset_password", LoginLive.UserForgotPasswordLive, :new
      live "/users/reset_password/:token", LoginLive.UserResetPasswordLive, :edit
    end

    post "/users/log_in", UserSessionController, :create
  end

  scope "/", LgbWeb do
    pipe_through [:browser, :require_authenticated_user]

    live_session :ensure_authenticated,
      on_mount: [{LgbWeb.UserAuth, :ensure_authenticated}, {LgbWeb.UserPresence, :track}] do
      live "/dashboard", DashboardLive
      live "/users/settings", LoginLive.UserSettingsLive, :edit
      live "/users/settings/confirm_email/:token", LoginLive.UserSettingsLive, :confirm_email

      live "/chat_rooms", ChatRoomLive.Index, :index
      live "/chat_rooms/:id", ChatRoomLive.Show, :show

      scope "/profiles", ProfileLive do
        live "/current", MyProfile
        live "/", Search
        live "/results", Results, :index
        live "/:id", Show, :show
      end

      live "/conversations", ConversationLive.Index, :index
      live "/conversations/:id", ConversationLive.Show, :show

      scope "/shopping", ShoppingLive do
        scope "/subscriptions", SubscriptionsLive do
          live "/", View
          live "/:id/info", Info
          live "/:id/checkout", Checkout
          live "/confirmed/payment/:id", Confirmed
        end
      end

      scope "/account", AccountLive do
        live "/", View
      end
    end
  end

  scope "/", LgbWeb do
    pipe_through [:browser]

    delete "/users/log_out", UserSessionController, :delete

    live_session :current_user,
      on_mount: [{LgbWeb.UserAuth, :mount_current_user}] do
      live "/users/confirm/:token", LoginLive.UserConfirmationLive, :edit
      live "/users/confirm", LoginLive.UserConfirmationInstructionsLive, :new
    end
  end
end
