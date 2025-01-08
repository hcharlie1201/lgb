defmodule Lgb.Repo do
  use Ecto.Repo,
    otp_app: :lgb,
    adapter: Ecto.Adapters.Postgres

  use EctoDbg
end
