# lib/your_app_web/controllers/waitlist_controller.ex
defmodule LgbWeb.WaitlistController do
  use LgbWeb, :controller
  alias Lgb.Waitlist

  def create(conn, %{"email" => email}) do
    case Waitlist.create_waitlist_entry(%{email: email}) do
      {:ok, _entry} ->
        conn
        |> put_flash(:info, "Thanks for joining our waitlist! We'll notify you when we launch.")
        |> redirect(to: ~p"/")

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "This email is already on the waitlist or is invalid.")
        |> redirect(to: ~p"/")
    end
  end
end
