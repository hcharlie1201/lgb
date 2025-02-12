defmodule Lgb.Accounts.UserNotifierTest do
  use Lgb.DataCase
  import Lgb.AccountsFixtures
  alias Lgb.Accounts.UserNotifier

  describe "deliver_confirmation_instructions/2" do
    test "delivers the email to the given user" do
      user = user_fixture()

      {:ok, email} =
        UserNotifier.deliver_confirmation_instructions(user, "http://example.com/confirm")

      assert email.to == [{"", user.email}]
      assert email.from == {"BiBi", "charles@bii-bi.com"}
      assert email.provider_options.template_id == "38664718"
      assert email.provider_options.template_model.product_url == "http://example.com/confirm"
    end
  end

  describe "deliver_reset_password_instructions/2" do
    test "delivers the email to the given user" do
      user = user_fixture()

      {:ok, email} =
        UserNotifier.deliver_reset_password_instructions(user, "http://example.com/reset")

      assert email.to == [{"", user.email}]
      assert email.from == {"BiBi", "charles@bii-bi.com"}
      assert email.provider_options.template_id == "38674222"
      assert email.provider_options.template_model.product_url == "http://example.com/reset"
    end
  end

  describe "deliver_update_email_instructions/2" do
    test "delivers the email to the given user" do
      user = user_fixture()

      {:ok, email} =
        UserNotifier.deliver_update_email_instructions(user, "http://example.com/update")

      assert email.to == [{"", user.email}]
      assert email.from == {"BiBi", "charles@bii-bi.com"}
      assert email.provider_options.template_id == "38674232"
      assert email.provider_options.template_model.product_url == "http://example.com/update"
    end
  end

  describe "email template model" do
    test "includes required template variables" do
      user = user_fixture()
      {:ok, email} = UserNotifier.deliver_confirmation_instructions(user, "http://example.com")

      template_model = email.provider_options.template_model

      assert template_model.invite_sender_name == "Charlie"
      assert template_model.product_name == "BiBi"
      assert template_model.email == user.email
      assert template_model.company_name == "BiBi"
      assert template_model.company_address == "1234 Main St"
    end
  end
end
