defmodule Lgb.Subscriptions do
  @moduledoc """
  The Subscriptions context.
  """

  import Ecto.Query, warn: false
  alias Lgb.Repo

  alias Lgb.Subscriptions.SubscriptionPlan

  @doc """
  Returns the list of subscrpition_plans.

  ## Examples

      iex> list_subscrpition_plans()
      [%SubscriptionPlan{}, ...]

  """
  def list_subscrpition_plans do
    Repo.all(SubscriptionPlan)
  end

  @doc """
    example response

  {
    "id": "price_1MoBy5LkdIwHu7ixZhnattbh",
    "object": "price",
    "active": true,
    "billing_scheme": "per_unit",
    "created": 1679431181,
    "currency": "usd",
    "custom_unit_amount": null,
    "livemode": false,
    "lookup_key": null,
    "metadata": {},
    "nickname": null,
    "product": "prod_NZKdYqrwEYx6iK",
    "recurring": {
      "aggregate_usage": null,
      "interval": "month",
      "interval_count": 1,
      "trial_period_days": null,
      "usage_type": "licensed"
    },
    "tax_behavior": "unspecified",
    "tiers_mode": null,
    "transform_quantity": null,
    "type": "recurring",
    "unit_amount": 1000,
    "unit_amount_decimal": "1000"
  }
  """

  def fetch_subscription_plan_metadata(subscription_plan) do
    http_response =
      Lgb.ThirdParty.Stripe.Plans.get!("/" <> subscription_plan.stripe_price_id)

    response =
      Poison.decode!(http_response.body)

    case Lgb.Repo.transaction(fn ->
           subscription_plan
           |> Map.put(:amount, response["unit_amount"])
           |> Map.put(:interval_count, response["recurring"]["interval_count"])
           |> Map.put(:interval, response["recurring"]["interval"])
         end) do
      {:ok, updated_subscription_plan} ->
        updated_subscription_plan

      {:error, _} ->
        subscription_plan
    end
  end

  @doc """
  Gets a single subscription_plan.

  Raises `Ecto.NoResultsError` if the Subscription plan does not exist.

  ## Examples

      iex> get_subscription_plan!(123)
      %SubscriptionPlan{}

      iex> get_subscription_plan!(456)
      ** (Ecto.NoResultsError)

  """
  def get_subscription_plan!(id), do: Repo.get!(SubscriptionPlan, id)

  @doc """
  Creates a subscription_plan.

  ## Examples

      iex> create_subscription_plan(%{field: value})
      {:ok, %SubscriptionPlan{}}

      iex> create_subscription_plan(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_subscription_plan(attrs \\ %{}) do
    %SubscriptionPlan{}
    |> SubscriptionPlan.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a subscription_plan.

  ## Examples

      iex> update_subscription_plan(subscription_plan, %{field: new_value})
      {:ok, %SubscriptionPlan{}}

      iex> update_subscription_plan(subscription_plan, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_subscription_plan(%SubscriptionPlan{} = subscription_plan, attrs) do
    subscription_plan
    |> SubscriptionPlan.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a subscription_plan.

  ## Examples

      iex> delete_subscription_plan(subscription_plan)
      {:ok, %SubscriptionPlan{}}

      iex> delete_subscription_plan(subscription_plan)
      {:error, %Ecto.Changeset{}}

  """
  def delete_subscription_plan(%SubscriptionPlan{} = subscription_plan) do
    Repo.delete(subscription_plan)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking subscription_plan changes.

  ## Examples

      iex> change_subscription_plan(subscription_plan)
      %Ecto.Changeset{data: %SubscriptionPlan{}}

  """
  def change_subscription_plan(%SubscriptionPlan{} = subscription_plan, attrs \\ %{}) do
    SubscriptionPlan.changeset(subscription_plan, attrs)
  end
end
