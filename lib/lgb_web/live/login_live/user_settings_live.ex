defmodule LgbWeb.LoginLive.UserSettingsLive do
  use LgbWeb, :live_view

  alias Lgb.Accounts
  alias Lgb.Feedbacks.Feedback
  alias Lgb.Feedbacks

  @feedback_categories [
    "User Experience",
    "Matching Algorithm",
    "Profile Features",
    "Messaging",
    "App Performance",
    "Suggestions",
    "Bug Report",
    "Other"
  ]

  @ratings [1, 2, 3, 4, 5]

  def render(assigns) do
    ~H"""
    <.header class="mt-4 text-center">
      <div class="logo-gradient text-2xl">Account Settings</div>
      <:subtitle>Manage your account email address and password settings</:subtitle>
    </.header>

    <div class="flex flex-col items-center space-y-12 divide-y p-4">
      <div class="w-[80vw] md:w-[60vw] lg:w-[50vw]">
        <.simple_form
          for={@email_form}
          id="email_form"
          phx-submit="update_email"
          phx-change="validate_email"
        >
          <.input field={@email_form[:email]} type="email" label="Email" required />
          <.input
            field={@email_form[:current_password]}
            name="current_password"
            id="current_password_for_email"
            type="password"
            label="Current password"
            value={@email_form_current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Email</.button>
          </:actions>
        </.simple_form>
      </div>
      <div class="w-[80vw] md:w-[60vw] lg:w-[50vw]">
        <.simple_form
          for={@password_form}
          id="password_form"
          action={~p"/users/log_in?_action=password_updated"}
          method="post"
          phx-change="validate_password"
          phx-submit="update_password"
          phx-trigger-action={@trigger_submit}
        >
          <input
            name={@password_form[:email].name}
            type="hidden"
            id="hidden_user_email"
            value={@current_email}
          />
          <.input field={@password_form[:password]} type="password" label="New password" required />
          <.input
            field={@password_form[:password_confirmation]}
            type="password"
            label="Confirm new password"
          />
          <.input
            field={@password_form[:current_password]}
            name="current_password"
            type="password"
            label="Current password"
            id="current_password_for_password"
            value={@current_password}
            required
          />
          <:actions>
            <.button phx-disable-with="Changing...">Change Password</.button>
          </:actions>
        </.simple_form>
      </div>

      <section>
        <.header class="mt-4 text-center">
          <div class="text-2xl">Share Your Feedback</div>
          <:subtitle>Help us improve your dating experience</:subtitle>
        </.header>

        <div class="flex flex-col items-center p-4">
          <div class="w-[90vw] md:w-[70vw] lg:w-[50vw]">
            <.simple_form
              for={@feedback_form}
              id="feedback_form"
              phx-submit="submit_feedback"
              phx-change="validate_feedback"
            >
              <div class="space-y-6">
                <.input
                  field={@feedback_form[:category]}
                  type="select"
                  name="user_feedback[category]"
                  label="What is your feedback about?"
                  options={@categories}
                  required
                />

                <div class="space-y-2">
                  <label class="block text-sm font-medium text-gray-700">
                    How would you rate your overall experience?
                  </label>
                  <div class="flex items-center justify-between py-2">
                    <span class="text-sm text-gray-500">Poor</span>
                    <div class="flex space-x-2">
                      <%= for rating <- @ratings do %>
                        <div class="flex flex-col items-center">
                          <input
                            type="radio"
                            name="user_feedback[rating]"
                            id={"rating-#{rating}"}
                            value={rating}
                            checked={@current_rating == rating}
                            class="h-4 w-4 border-gray-300 text-indigo-600 focus:ring-indigo-600"
                            phx-click="set_rating"
                            phx-value-rating={rating}
                          />
                          <label for={"rating-#{rating}"} class="mt-1 text-xs">
                            {rating}
                          </label>
                        </div>
                      <% end %>
                    </div>
                    <span class="text-sm text-gray-500">Excellent</span>
                  </div>
                </div>

                <.input
                  field={@feedback_form[:title]}
                  type="text"
                  name="user_feedback[title]"
                  label="Feedback Summary"
                  placeholder="Brief description of your feedback"
                  required
                />

                <.input
                  field={@feedback_form[:content]}
                  type="textarea"
                  label="Details"
                  name="user_feedback[content]"
                  placeholder="Please share the details of your experience or suggestion..."
                  rows={5}
                  required
                />

                <div class="py-3">
                  <label class="flex items-center gap-2 text-sm">
                    <input
                      type="checkbox"
                      name="user_feedback[contact_consent]"
                      checked={@contact_consent}
                      phx-click="toggle_consent"
                      class="h-4 w-4 border-gray-300 text-indigo-600 focus:ring-indigo-600"
                    />
                    <span>I consent to being contacted about my feedback</span>
                  </label>
                </div>
              </div>

              <:actions>
                <.button phx-disable-with="Submitting..." class="w-full">
                  Submit Feedback
                </.button>
              </:actions>
            </.simple_form>
          </div>
        </div>
      </section>
    </div>
    """
  end

  def mount(%{"token" => token}, _session, socket) do
    socket =
      case Accounts.update_user_email(socket.assigns.current_user, token) do
        :ok ->
          put_flash(socket, :info, "Email changed successfully.")

        :error ->
          put_flash(socket, :error, "Email change link is invalid or it has expired.")
      end

    {:ok, push_navigate(socket, to: ~p"/users/settings")}
  end

  def mount(_params, _session, socket) do
    user = socket.assigns.current_user
    email_changeset = Accounts.change_user_email(user)
    password_changeset = Accounts.change_user_password(user)
    changeset = Feedbacks.change_user_feedback(%Feedback{})

    socket =
      socket
      |> assign(:email_form, to_form(email_changeset))
      |> assign(:password_form, to_form(password_changeset))
      |> assign(:feedback_form, to_form(changeset))
      |> assign(:current_email, user.email)
      |> assign(:current_password, nil)
      |> assign(:email_form_current_password, nil)
      |> assign(:trigger_submit, false)
      |> assign(:categories, @feedback_categories)
      |> assign(:ratings, @ratings)
      |> assign(:current_rating, 3)
      |> assign(:contact_consent, false)

    {:ok, socket}
  end

  def handle_event("validate_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    email_form =
      socket.assigns.current_user
      |> Accounts.change_user_email(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, email_form: email_form, email_form_current_password: password)}
  end

  def handle_event("update_email", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.apply_user_email(user, password, user_params) do
      {:ok, applied_user} ->
        Accounts.deliver_user_update_email_instructions(
          applied_user,
          user.email,
          &url(~p"/users/settings/confirm_email/#{&1}")
        )

        info = "A link to confirm your email change has been sent to the new address."
        {:noreply, socket |> put_flash(:info, info) |> assign(email_form_current_password: nil)}

      {:error, changeset} ->
        {:noreply, assign(socket, :email_form, to_form(Map.put(changeset, :action, :insert)))}
    end
  end

  def handle_event("validate_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params

    password_form =
      socket.assigns.current_user
      |> Accounts.change_user_password(user_params)
      |> Map.put(:action, :validate)
      |> to_form()

    {:noreply, assign(socket, password_form: password_form, current_password: password)}
  end

  def handle_event("update_password", params, socket) do
    %{"current_password" => password, "user" => user_params} = params
    user = socket.assigns.current_user

    case Accounts.update_user_password(user, password, user_params) do
      {:ok, user} ->
        password_form =
          user
          |> Accounts.change_user_password(user_params)
          |> to_form()

        {:noreply, assign(socket, trigger_submit: true, password_form: password_form)}

      {:error, changeset} ->
        {:noreply, assign(socket, password_form: to_form(changeset))}
    end
  end

  def handle_event("validate_feedback", %{"user_feedback" => feedback_params}, socket) do
    IO.inspect(feedback_params)

    changeset =
      %Feedback{}
      |> Feedbacks.change_user_feedback(feedback_params)
      |> Map.put(:action, :validate)

    IO.inspect(changeset)

    {:noreply, assign(socket, :feedback_form, to_form(changeset))}
  end

  def handle_event("submit_feedback", %{"user_feedback" => feedback_params}, socket) do
    current_profile = Accounts.User.current_profile(socket.assigns.current_user)

    feedback_params = Map.put(feedback_params, "profile_id", current_profile.id)

    case Feedbacks.create_user_feedback(feedback_params) do
      {:ok, _feedback} ->
        {:noreply,
         socket
         |> put_flash(:info, "Thank you for your feedback! We appreciate your input.")
         |> push_navigate(to: ~p"/")}

      {:error, changeset} ->
        {:noreply, assign(socket, feedback_form: to_form(changeset))}
    end
  end

  def handle_event("set_rating", %{"rating" => rating}, socket) do
    {:noreply, assign(socket, :current_rating, String.to_integer(rating))}
  end

  def handle_event("toggle_consent", _params, socket) do
    {:noreply, assign(socket, :contact_consent, !socket.assigns.contact_consent)}
  end
end
