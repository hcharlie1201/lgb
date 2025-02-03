defmodule Lgb.Accounts.UserNotifier do
  import Swoosh.Email

  alias Lgb.Mailer

  # Delivers the email using the application mailer.
  defp deliver(recipient, template_id, url) do
    email =
      new()
      |> to(recipient)
      |> from({"Lgb", "charlie@bii-bi.com"})
      |> put_provider_option(:template_id, template_id)
      |> put_provider_option(:template_model, %{
        invite_sender_name: "Charlie",
        product_name: "BiBi",
        product_url: url,
        # currently for testing it has to end with @bii-bi.com
        email: recipient,
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
    deliver(user.email, "38664718", url)
  end

  @doc """
  Deliver instructions to reset a user password.
  """
  def deliver_reset_password_instructions(user, url) do
    deliver(user.email, "38674222", url)
  end

  @doc """
  Deliver instructions to update a user email.
  """
  def deliver_update_email_instructions(user, url) do
    deliver(user.email, "38674232", url)
  end
end
