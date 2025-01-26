defmodule Lgb.AccountsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Lgb.Accounts` context.
  """

  def unique_user_email, do: "user#{System.unique_integer()}@example.com"
  def valid_user_password, do: "hello world!"
  def valid_user_hashed_password, do: Bcrypt.hash_pwd_salt(valid_user_password())

  def valid_user_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email: unique_user_email(),
      password: valid_user_password(),
      password_confirmation: valid_user_password()
    })
  end

  def user_fixture(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> valid_user_attributes()
      |> Lgb.Accounts.register_user()

    Lgb.Repo.transaction(confirm_user_multi(user))
    user
  end

  def extract_user_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")

    [_, token | _] =
      String.split(captured_email.provider_options.template_model.product_url, "[TOKEN]")

    token
  end

  def confirm_user_multi(user) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:user, Lgb.Accounts.User.confirm_changeset(user))
    |> Ecto.Multi.delete_all(
      :tokens,
      Lgb.Accounts.UserToken.by_user_and_contexts_query(user, ["confirm"])
    )
  end
end
