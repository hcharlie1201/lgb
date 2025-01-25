defmodule Lgb.Billing.StripeSubscription do
  use Ecto.Schema
  import Ecto.Changeset

  schema "stripe_subscriptions" do
    belongs_to :stripe_customer, Lgb.Billing.StripeCustomer
    # Stripe number
    field :subscription_id, :string
    field :subscription_plan_id, :integer

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(stripe_subscription, attrs) do
    stripe_subscription
    |> cast(attrs, [:subscription_id, :stripe_customer_id, :subscription_plan_id])
    |> validate_required([:subscription_id, :stripe_customer_id, :subscription_plan_id])
  end

  def get_metadata(stripe_subscription) do
    case Lgb.ThirdParty.Stripe.Subscriptions.get("/#{stripe_subscription.subscription_id}") do
      {:ok, http_response} ->
        {:ok, Poison.decode!(http_response.body)}

      {:error, http_error} ->
        {:error, http_error.reason}
    end
  end

  # https://docs.stripe.com/billing/subscriptions/build-subscriptions?ui=elements#create-pricing-model
  def get_client_secret(metadata) do
    with {:ok, invoice} <- get_invoice(metadata["latest_invoice"]),
         {:ok, payment_intent} <- get_payment_intent(invoice["payment_intent"]) do
      {:ok, payment_intent["client_secret"]}
    else
      {:error, message} -> {:error, message}
    end
  end

  def get_payment_intent_from_metadata(metadata) do
    with {:ok, invoice} <- get_invoice(metadata["latest_invoice"]),
         {:ok, payment_intent} <- get_payment_intent(invoice["payment_intent"]) do
      {:ok, payment_intent}
    else
      {:error, message} -> {:error, message}
    end
  end

  def get_invoice(invoice_id) do
    case Lgb.ThirdParty.Stripe.Invoices.get("/#{invoice_id}") do
      {:ok, http_response} ->
        Poison.decode(http_response.body)

      {:error, http_error} ->
        {:error, http_error.reason}
    end
  end

  def get_payment_intent(payment_intent_id) do
    case Lgb.ThirdParty.Stripe.PaymentIntents.get("/#{payment_intent_id}") do
      {:ok, http_response} -> Poison.decode(http_response.body)
      {:error, http_error} -> {:error, http_error.reason}
    end
  end
end
