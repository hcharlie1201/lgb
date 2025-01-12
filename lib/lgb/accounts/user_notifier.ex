defmodule Lgb.Accounts.UserNotifier do
  import Swoosh.Email

  alias Lgb.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, subject, body) do
    email =
      new()
      |> to(recipient)
      |> from({"Lgb", "charlie@bii-bi.com"})
      |> put_provider_option(:template_id, "38664718")
      |> put_provider_option(:template_model, %{
        invite_sender_name: "John Doe",
        product_name: "BiBi",
        product_url: "asdasd",
        email: "charlie@bii-bi.com",
        token: "123456",
        company_name: "BiBi",
        company_address: "1234 Main St"
      })

    case Mailer.deliver(email) do
      {:ok, _metadata} ->
        {:ok, email}

      {:error, reason} ->
        {:ok, email}
    end
  end

  @doc """
  Deliver instructions to confirm account.
  """
  def deliver_confirmation_instructions(user, url) do
    deliver(user.email, "Confirmation instructions", """

    ==============================

    Hi #{user.email},

    You can confirm your account by visiting the URL below:

    #{url}

    If you didn't create an account with us, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "Reset password instructions", """

    ==============================

    Hi #{user.email},

    You can reset your password by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "Update email instructions", """

    ==============================

    Hi #{user.email},

    You can change your email by visiting the URL below:

    #{url}

    If you didn't request this change, please ignore this.

    ==============================
    """)
  end
end
