defmodule LgbWeb.LoginLive.UserLoginLive do
  use LgbWeb, :live_view

  def render(assigns) do
    ~H"""
    <div class="mx-auto max-w-sm">
      <.header class="text-center">
        Log in to account
        <:subtitle>
          Don't have an account?
          <.link navigate={~p"/users/register"} class="font-semibold text-blue-600 hover:underline">
            Sign up
          </.link>
          for an account now.
        </:subtitle>
      </.header>

      <.simple_form for={@form} id="login_form" action={~p"/users/log_in"} phx-update="ignore">
        <.input field={@form[:email]} type="email" label="Email" required />
        <.input field={@form[:password]} type="password" label="Password" required />

        <:actions>
          <.input field={@form[:remember_me]} type="checkbox" label="Keep me logged in" />
          <.link href={~p"/users/reset_password"} class="text-sm font-semibold">
            Forgot your password?
          </.link>
        </:actions>
        <:actions>
          <.button phx-disable-with="Logging in..." class="w-full">
            Log in
          </.button>
        </:actions>
      </.simple_form>

      <div class="relative my-6">
        <div class="absolute inset-0 flex items-center">
          <div class="w-full border-t border-gray-300"></div>
        </div>
        <div class="relative flex justify-center">
          <span class="bg-white px-4 text-sm text-gray-500">Or continue with</span>
        </div>
      </div>

      <div class="mt-4">
        <.link href={~p"/auth/google"}>
          <.button class="flex w-full items-center justify-center rounded-lg px-6 py-2 text-sm shadow-md hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2">
            <svg class="mr-2 h-6 w-6" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">
              <path
                fill="#4285F4"
                d="M45.12 24.5c0-1.56-.14-3.06-.4-4.5H24v8.51h11.84c-.51 2.75-2.06 5.08-4.42 6.63v5.52h7.15c4.16-3.83 6.55-9.47 6.55-16.16z"
              />
              <path
                fill="#34A853"
                d="M24 46c5.94 0 10.92-1.97 14.56-5.33l-7.15-5.52c-1.97 1.32-4.49 2.1-7.41 2.1-5.7 0-10.54-3.85-12.28-9.04H4.34v5.7C7.96 41.07 15.4 46 24 46z"
              />
              <path
                fill="#FBBC05"
                d="M11.72 28.21c-.44-1.32-.69-2.73-.69-4.21s.25-2.89.69-4.21V14.1H4.34A23.91 23.91 0 0 0 0 24c0 3.87.93 7.53 2.56 10.78l7.16-5.57z"
              />
              <path
                fill="#EA4335"
                d="M24 9.75c3.22 0 6.12 1.11 8.4 3.3l6.3-6.3C34.91 3.19 29.93 1 24 1 15.4 1 7.96 5.93 4.34 14.1l7.38 5.7c1.74-5.19 6.58-9.04 12.28-9.04z"
              />
            </svg>
            Continue with Google
          </.button>
        </.link>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    email = Phoenix.Flash.get(socket.assigns.flash, :email)
    form = to_form(%{"email" => email}, as: "user")
    {:ok, assign(socket, form: form), temporary_assigns: [form: form]}
  end
end
